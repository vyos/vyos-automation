# AWS_terraform_ansible_single_vyos_instance
How to create a single instance and install your configuration using Terraform+Ansible+AWS 
Step by step:
# AWS
1.1 Create an account with AWS and get your "access_key", "secret key"

1.2 Create a key pair and download your .pem key

1.3 Create a security group for the new VyOS instance
# Terraform
2.1 Create a UNIX or Windows instance

2.2 Download and install Terraform

2.3 Create the folder for example ../awsvyos/

2.4 Copy all files from my folder /Terraform into your Terraform project (vyos.tf, var.tf)
2.4.1 Please type the information into the strings 22, 35, 36 of file "vyos.tf"

2.5 Type the commands :

   #cd /your folder
   
   #terraform init
# Ansible
3.1 Create a UNIX instance

3.2 Download and install Ansible

3.3 Create the folder for example /root/aws/

3.4 Copy all files from my folder /Ansible into your Ansible project (ansible.cfg, instance.yml, mykey.pem)

mykey.pem you have to get using step 1.2
# Start 
4.1 Type the commands on your Terrafom instance:
   
   #cd /your folder 

   #terraform plan  

   #terraform apply  
   
   #yes

![ezcv logo](/images/aws.png)
