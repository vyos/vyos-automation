# VyOS Deployment with Advanced Configuration

## Overview
This manual guides the deployment of a VyOS instance in AWS using CloudFormation. The template sets up:
- VPC with public and private subnets
- Internet Gateway, Route Tables, ENIs, Security Groups, Elastic IP
- Configuration via cloud-init

This automated setup ensures a consistent, efficient deployment process.

## Prerequisites
- **AWS Account**: Permissions to manage VPCs, EC2 instances, etc.
- **EC2 Key Pair**: Valid SSH key for accessing VyOS.
- **AWS Console/CLI**: Familiarity with AWS Console or CLI for stack management.

## CloudFormation Template Overview

### Parameters

#### Existing VPC and Subnet Parameters
For deployment to an existing VPC, provide VPC and Subnet IDs; leave blank for a new VPC.
- **ExistingVPCId**: (Optional) VPC ID
- **ExistingPublicSubnetId**: (Optional) Public Subnet ID
- **ExistingPrivateSubnetId**: (Optional) Private Subnet ID

#### New VPC Parameters
For a new VPC, specify:
- **VPCName**: Name of the new VPC
- **VPCCidrBlock**: CIDR block (e.g., 10.0.0.0/16)

#### Subnet Parameters
- **PublicSubnetCidr**: CIDR for the public subnet
- **PrivateSubnetCidr**: CIDR for the private subnet

#### VyOS Instance Parameters
- **InstanceType**: EC2 instance type (e.g., t3.medium)
- **KeyName**: Name of EC2 KeyPair
- **VyOSPublicENIip**: Private IP in the public subnet
- **VyOSPrivENIip**: Private IP in the private subnet
- **VyOSBGPASNumber**: BGP ASN for VyOS
- **DNS1/DNS2**: Primary/Secondary DNS IP
- **SSHAllowedIP**: CIDR for SSH access (e.g., 192.0.2.0/24)
- **AmiAlias**: Specify VyOS AMI alias (e.g., `latest` or version `/aws/.../1.4.0`)

#### BGP/VPN Peer Parameters
- **OnPremPublicIPAddress**: Public IP of on-premise VPN endpoint
- **OnPremBGPASNumber**: BGP ASN for on-premise endpoint

### Resources
1. **VPC**: Creates a new VPC or uses an existing one
2. **Subnets**: Public and private subnets
3. **Internet Gateway**: For public subnet internet access
4. **Route Tables**: Routing configuration for traffic between subnets and Internet Gateway
5. **ENIs**: Elastic Network Interfaces for public and private IPs
6. **Security Groups**: Public/Private Security Groups
7. **VyOS Instance**: Configured via cloud-init with specified AMI and instance type

### Conditions
Conditions determine whether to create a new VPC or use an existing one.

## Deployment Scenarios

### Existing VPC Deployment
1. In **AWS Console**, go to **CloudFormation** > **Create Stack**
2. Choose **Upload a template** and select the `.yaml` file
3. Enter **Stack Details** and existing **VPC/Subnet IDs**
4. Configure **VyOS Instance Parameters**
5. Add on-prem VyOS parameters and finish deployment
6. Confirm **CREATE_COMPLETE** status and retrieve Public IP from **Outputs**

### New VPC Deployment
1. Follow the steps above but add new **VPC name, CIDR, and Subnet CIDRs**
2. Complete **VyOS Instance Configuration**
3. Confirm deployment and retrieve Public IP from **Outputs**

## Access and Management
Use SSH to connect:
```bash
ssh vyos@<VyOS_Public_IP_Address> -i <test-key.pem>
```

## Common Commands for VyOS Management

- **show configuration commands**: Displays the current configuration.
- **show interfaces**: Lists all network interfaces and their status.
- **show ip route**: Shows the IP routing table.
- **show ip bgp summary**: Summarizes BGP neighbors and sessions.
- **show vpn ipsec sa**: Displays the status of IPsec Security Associations.
- **show vpn ike sa**: Shows the status of IKE Security Associations.
- **show vpn ipsec connections**: Lists current IPsec VPN connections.
- **show firewall summary**: Summarizes firewall rules and statistics.
- **show firewall statistics**: Provides detailed firewall statistics.

For additional commands and configurations, refer to the [VyOS Documentation](https://docs.vyos.io/en/sagitta/).

