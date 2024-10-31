# VyOS Deployment with Basic Configuration

## Template Overview

This CloudFormation template automates the deployment of a VyOS instance, setting up:
- A VPC with public and private subnets.
- Internet Gateway, Route Tables, ENIs, Security Groups, and Elastic IP.
- Configuration via cloud-init for a consistent, scalable setup.

## Prerequisites

Ensure the following prerequisites are met before deploying:
- **AWS Account**: Active with necessary IAM permissions for VPCs, EC2 instances, etc.
- **EC2 Key Pair**: Valid SSH key pair for instance access.
- **AWS CLI/Console Access**: Familiarity with AWS Console or CLI for managing the CloudFormation stack.

## Deployment Scenarios

### Deploying to an Existing VPC

1. Go to **AWS Console** > **CloudFormation**.
2. Select **Create stack** - with new resources.
3. Upload the `.yaml` template file.
4. Specify stack details:
   - **Stack name**.
   - **Existing VPC and Subnet IDs** (must belong to the same AWS region and Availability Zone).
5. Leave new VPC and Subnet CIDR fields empty.
6. Configure VyOS Instance parameters:
   - **Instance Type**.
   - **EC2 Key Pair Name**.
   - **ENI IPs** (according to the existing subnet CIDRs).
   - **Primary and Secondary DNS** (optional).
   - **SSH Allowed IP Subnet** (for remote access).

    > **Note**: Setting `VyOS AMI Alias` to `latest` will deploy the latest version. Specify a specific version if needed, e.g., `/aws/service/marketplace/prod-ev235jujteaom/1.4.0`.

7. Monitor stack creation until the **CREATE_COMPLETE** message appears.
8. Retrieve the Public IP in the “Outputs” tab.

### Deploying to a New VPC

1. Go to **AWS Console** > **CloudFormation**.
2. Select **Create stack** - with new resources.
3. Upload the `.yaml` template file.
4. Specify stack details:
   - **New VPC name and CIDR**.
   - **Public and Private Subnet CIDRs**.
5. Leave existing VPC/Subnet IDs empty.
6. Configure VyOS Instance parameters as listed above.
7. Wait for **CREATE_COMPLETE** and find the Public IP under “Outputs”.

## Access and Management

To connect to the VyOS instance, use:
- **VyOS Public IP** (from Outputs) and **EC2 Key Pair** with an SSH client.

Sample command: `ssh vyos@<VyOS_Public_IP_Address> -i <test-key.pam>`

### Common CLI Commands

For VyOS configuration and interface checking:
```bash
show configuration commands
show interfaces
show ip route
