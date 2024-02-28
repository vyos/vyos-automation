# Azure_terraform_ansible_single_vyos_instance
How to create a single instance and install your configuration using Terraform+Ansible+Azure 
Step by step:
# Azure
1.1 Create an account with Azure
# Terraform
2.1 Create a UNIX or Windows instance

2.2 Download and install Terraform

2.3 Create the folder for example ../azvyos/

2.4 Copy all files from my folder /Terraform into your Terraform project (main.tf, variables.tf)

2.5 Login with Azure  using the command 

  #az login

2.6 Type the commands :

   #cd /your folder
   
   #terraform init
# Ansible
3.1 Create a UNIX instance

3.2 Download and install Ansible

3.3 Create the folder for example /root/az/

3.4 Copy all files from my folder /Ansible into your Ansible project (ansible.cfg, instance.yml and /group_vars)

# Start 
4.1 Type the commands on your Terrafom instance:
   
   #cd /your folder 

   #terraform plan  

   #terraform apply  
   
   #yes
