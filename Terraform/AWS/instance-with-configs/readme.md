# Terraform Project for deploying VyOS on AWS

This Terraform project is designed to deploy VyOS instances on AWS. This script deploys a VyOS instance from the AWS Marketplace.

## Prerequisites

Before applying this module, ensure you have:

### AWS Requirements

- An active AWS account.
- AWS CLI installed. [Installation link](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html)
- Terraform installed. [Installation link](https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install-cli)

### Set AWS environment variables

- Run the following commands in your terminal to set the AWS environment variables:

```sh
export AWS_ACCESS_KEY_ID="<AWS_ACCESS_KEY_ID>"
export AWS_SECRET_ACCESS_KEY="<WS_SECRET_ACCESS_KEY>"
export AWS_SESSION_TOKEN="<AWS_SESSION_TOKEN>"
export AWS_DEFAULT_REGION="<AWS_REGION>" # e.g us-east-1
```

### Fetch AMI ID and Owner ID (Required for main.tf)
First, you must subscribe to VyOS in the AWS Marketplace.
Then, use the following AWS CLI command to find the correct AMI ID, Owner ID, and ensure you're querying the correct region (e.g., `us-east-1`):

```sh
aws ec2 describe-images \
  --owners aws-marketplace \
  --filters "Name=product-code,Values=8wqdkv3u2b9sa0y73xob2yl90" \
  --query 'Images[*].[ImageId,OwnerId,Name]' \
  --output table
```
Alternatively, you can hardcode the latest AMI ID for your region in `variables.tf` adding the `vyos_ami_id` variable.

### Generate SSH keypair

A demo SSH keypair is included in the `keys/` folder.

To generate a new key (optional):

```sh
ssh-keygen -b 2048 -t rsa -m PEM -f keys/vyos_custom_key.pem
```

## Project Structure

```
.
├── files/                      # VyOS user-data
├── keys/                       # Pre-generated SSH keys
├── network.tf                  # Network setup
├── provider.tf                 # Provider configuration
├── security_groups.tf          # Security group configurations
├── variables.tf                # Input variables for customization
├── vyos_instance.tf            # VyOS virtual machine deployment (AWS)
└── README.md                   # Documentation
```

## Usage

### Setup Variables

All variables needed for customization are defined in `variables.tf`. Adjust them according to your requirements, such as EC2 instance type and networking configurations. Before deployment, ensure you check `aws_region`, `availability_zone`, and update `vyos_ami_id` as necessary.

## How to Run the Module

Follow these steps to initialize, plan, apply, and manage your infrastructure with Terraform:

1. **Initialize the Module**
   ```sh
   terraform init
   ```

2. **Format the Terraform Code**
   ```sh
   terraform fmt
   ```

3. **Validate Configuration**
   ```sh
   terraform validate
   ```

4. **Preview Infrastructure Changes Before Deployment**
   ```sh
   terraform plan
   ```

5. **Apply the Configuration**
   ```sh
   terraform apply
   ```
   Confirm the execution when prompted to provision the infrastructure.

6. **View Outputs**
   ```sh
   terraform output
   ```
   This will display the management IP and test results for the VyOS instance.

## Management

To manage the VyOS instance, use the `vyos_public_ip` from `terraform output`:
```sh
ssh vyos@<vyos_public_ip> -i keys/vyos_demo_private_key.pem
```
You can find op-premise (peer) side VyOS configuration reference from: `files/on-prem-vyos-config.txt`

## Destroying Resources

To clean up the deployed infrastructure:
```sh
terraform destroy
```
Confirm the execution when prompted to remove all provisioned resources.

