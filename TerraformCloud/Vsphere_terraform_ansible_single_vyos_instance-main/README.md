# Azure_terraform_ansible_single_vyos_instance
How to create a single instance and install your configuration using Terraform+Ansible+Vsphere 
Step by step:
# Vsphere
1.1 Collect all data in to file "terraform.tfvars" and create resources fo example "terraform"
# Terraform
2.1 Create a UNIX or Windows instance

2.2 Download and install Terraform

2.3 Create the folder for example ../vsphere/

2.4 Copy all files from my folder /Terraform into your Terraform project

2.5 Type the commands :

   #cd /your folder
   
   #terraform init

# Ansible
3.1 Create a UNIX instance

3.2 Download and install Ansible

3.3 Create the folder for example /root/vsphere/

3.4 Copy all files from my folder /Ansible into your Ansible project (ansible.cfg, instance.yml and /group_vars)

# Start 
4.1 Type the commands on your Terrafom instance:
   
   #cd /your folder 

   #terraform plan  

   #terraform apply  
   
   #yes
