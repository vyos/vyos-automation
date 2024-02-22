from phabricator_patched import Phabricator
import argparse

'''
get project wide tasks which are not closed but all in the Finished column

1. get all Workboard columns
    - extract workboard phid for the Finished column
    - and the project phid and name

2. get all open taks from projects with Finish column
3. get unique taskslists from previous step to get projekts of a task
4. get all transactions for each task and check if the task is in the Finished column per project
5. autoclose if task is in all Finished column

'''


def phab_search(method, constraints=dict(), after=None):
    results = []
    while True:
        response = method(
            constraints=constraints,
            after=after
        )
        results.extend(response.response['data'])
        after = response.response['cursor']['after']
        if after is None:
            break
    return results


def phab_query(method, after=None):
    results = []
    while True:
        response = method(
            offset=after
        )
        results.extend(response.response['data'])
        after = response.response['cursor']['after']
        if after is None:
            break
    return results


def close_task(task_id, phab):
    try:
        response = phab.maniphest.update(
            id=task_id,
            status='resolved'
        )
        if response.response['isClosed']:
            print(f'T{task_id} closed')
    except Exception as e:
        print(f'T{task_id} Error: {e}')


parser = argparse.ArgumentParser()
parser.add_argument("-t", "--token", type=str, help="API token", required=True)
args = parser.parse_args()

phab = Phabricator(host='https://vyos.dev/api/', token=args.token)
phab.maniphest.update(id=6053, status='resolved')

workboards = phab_search(phab.project.column.search)

project_hirarchy = {}

# get sub-project hirarchy from proxyPHID in workboards
for workboard in workboards:
    if workboard['fields']['proxyPHID']:
        proxy_phid = workboard['fields']['proxyPHID']
        project_phid = workboard['fields']['project']['phid']

        if project_phid not in project_hirarchy.keys():
            project_hirarchy[project_phid] = []
        project_hirarchy[project_phid].append(proxy_phid)

finished_boards = []


for workboard in workboards:
    project_id = workboard['fields']['project']['phid']
    if project_id in project_hirarchy.keys():
        # skip projects with sub-projects
        continue
    if workboard['fields']['name'] == 'Finished':
        project_tasks = phab_search(phab.maniphest.search, constraints={
                    'projects': [project_id],
                    'statuses': ['open'],
        })
        finished_boards.append({
            'project_id': project_id,
            'project_name': workboard['fields']['project']['name'],
            'project_tasks': project_tasks,
            'should_board_id': workboard['phid'],    
        })

# get unique tasks
# tasks = {
#     9999: {
#         'PHID-PROJ-xxxxx': 'PHID-PCOL-xxxxx',
#         'PHID-PROJ-yyyyy': 'PHID-PCOL-yyyyy'
#     }
# }
tasks = {}
for project in finished_boards:
    project_id = project['project_id']
    board_id = project['should_board_id']
    for task in project['project_tasks']:
        task_id = task['id']
        if task_id not in tasks.keys():
            tasks[task_id] = {}
        if project_id not in tasks[task_id].keys():
            tasks[task_id][project_id] = board_id

tasks = dict(sorted(tasks.items()))

# get transactions for each task and compare if the task is in the Finished column
for task_id, projects in tasks.items():
    fisnish_timestamp = 0
    project_ids = list(projects.keys())
    # don't use own pagination function, because endpoint without pagination
    transactions = phab.maniphest.gettasktransactions(ids=[task_id])
    transactions = transactions.response[str(task_id)]
    finished = False
    for transaction in transactions:
        if transaction['transactionType'] == 'core:columns':
            # test if projectid is in transaction
            if transaction['newValue'][0]['boardPHID'] in project_ids:
                # remove project_id from project_ids to use only last transaction in this
                # project
                project_ids.remove(transaction['newValue'][0]['boardPHID'])
                # test if boardid is the "Finished" board
                if fisnish_timestamp < int(transaction['dateCreated']):
                    fisnish_timestamp = int(transaction['dateCreated'])
                if projects[transaction['newValue'][0]['boardPHID']] == transaction['newValue'][0]['columnPHID']:
                    finished = True
                    for project in finished_boards:
                        if project['project_id'] == transaction['newValue'][0]['boardPHID']:
                            project_name = project['project_name']
                    # print(f'T{task_id} is Finished in {project_name}')
        if len(project_ids) == 0:
            print(f'T{task_id} is Finished in all projects')
            close_task(task_id, phab)
            break
    
    #if len(project_ids) > 0 and finished:
        # collect project names for output
    #    project_names = []
    #    for project_id in project_ids:
    #        for project in finished_boards:
    #            if project['project_id'] == project_id:
    #                project_names.append(project['project_name'])
    #    print(f'T{task_id} is in a different column: {' and '.join(project_names)}')
    