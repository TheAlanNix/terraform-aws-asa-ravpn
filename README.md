# ASAv: Remote Access VPN in AWS

This is a Terraform template meant to quickly configure multiple Cisco ASAv instances, across multiple availability zones, in AWS.

## Requirements

1. Must have an AWS account.
2. Must have Terraform installed. 

## Installation

### AWS Credentials

You'll need to have an AWS account, and you'll want to set up configuration and credentials files on your system as outlined in the guide here:

https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-files.html

### Terraform

Once you've configured your AWS credentials file, you'll need to install Terraform.  If you've never used Terraform before, they provide detailed documentation and tutorials here:

https://learn.hashicorp.com/terraform#getting-started

## Applying the Terraform Template

To apply this template, follow the steps below:

1. Understand what an AWS Transit Gateway is, and why it is used.
    - Decide whether you want to create a new Transit Gateway, or leverage an existing one.
2. Set up the configuration parameters in the **[terraform.tfvars](terraform.tfvars)** file.
    - Configuration variables and their default values are described below.
3. Initialize Terraform by running `terraform init` from the root directory of this repository.
4. Verify the Terraform configuration by running `terraform plan` to preview the changes that will be made.
5. Once verified, simply run `terraform apply` to deploy your RAVPN infrastructure.
6. During deployment, a password.txt file will be created in the root directory of the repository which contains a 40-character random password for the 'admin' account on the ASAv instances.  This is also used for the enable password.
7. When deployment is complete, you can access the management or inside interfaces of the ASAv by default.  It's also possible to connect to the outside IP address, but you must manually edit the AWS Security Group to allow SSH/HTTPS in order to do so.

### AWS Transit Gateway

This script will leverage an AWS Transit Gateway to tunnel traffic to/from the created AWS VPC to your networks.  High-level design of AWS Site-to-Site VPN designs, including Transit Gateways, can be found here:

https://docs.aws.amazon.com/vpn/latest/s2svpn/how_it_works.html#Transit-Gateway

#### Option 1: Create a new Transit Gateway

The default configuration will create a new Transit Gateway and build the appropriate route tables.  You will then need to create a Customer Gateway and configure your Site-to-Site VPN tunnel(s) to AWS in order to allow RAVPN users to access internal resources.

#### Option 2: Leverage an existing Transit Gateway

You can leverage an existing AWS Transit Gateway by importing it into Terraform's "state" by running the following command:

`terraform import aws_ec2_transit_gateway.transit_gateway <Transit_Gateway_ID>`

Upon importing an existing Transit Gateway, you'll want to verify the `terraform plan` data to make sure that it is simply going to modify the existing Transit Gateway, rather than re-creating it.  This may mean you need to manually sync things like name/description.

Also, prior to running a `terraform destroy` you'll want to remove the existing transit gateway to prevent it from being destroyed.  If there are existing attachments to the Transit Gateway, it should prevent deletion - but better safe than sorry.  To remove the existing Transit Gateway from Terraform, simply run the following command:

`terraform state rm aws_ec2_transit_gateway.transit_gateway`

For more information on Transit Gateways, please see Amazon's full documentation here:

https://docs.aws.amazon.com/vpc/latest/tgw/tgw-transit-gateways.html

### Configuration Parameters

Once your environment is set up, you'll want to edit the **[terraform.tfvars](terraform.tfvars)** file in this repository to specify configuration for your ASAv-RAVPN deployment.  Configuration variables are as follows:

- availability_zone_count:  The number of availability zones in which to deploy.
  - Default: 1
  - Type: Integer
- instance_size:  The desired instance size for the ASAv instances.
  - Default: "c5.2xlarge"
  - Type: String
  - Values: c5.large (ASAv10) / c5.xlarge (ASAv30) / c5.2xlarge (ASAv50)
- instances_per_az:  The number of ASAv instances per availability zone.
  - Default: 1
  - Type: Integer
- internal_networks:  The internal networks that should be accessible to RAVPN clients.  This is used to set up routing and AWS Security Groups.
  - Default: ["10.0.0.0/8", "172.16.0.0/12", "192.168.0.0/16"]
  - Type: List of CIDR networks
- region:  The AWS Region that you'd like to deploy to.
  - Default: "us-east-1"
  - Type: String
- smart_account_token:  (Optional) The Smart License Registration Token that you would like to use.
  - Default: ""
  - Type: String
- vpc_name:  The desired name of the VPC that will be created.
  - Default: "ASAv Remote Access VPN"
  - Type: String
- vpc_subnet:  **[REQUIRED]** The CIDR network that should be used to assign subnets in AWS.  This will be used for interfaces on the ASAv instances.
  - Default: "10.150.0.0/24"
  - Type: String
- vpn_pool_dns:  (Optional) A comma-separated list of the default DNS servers to be used by RAVPN clients.
  - Default: ""
  - Type: String
- vpn_pool_supernet:  **[REQUIRED]** The CIDR network that should be used to assign VPN IP pools for RAVPN users.
  - Default: "10.151.0.0/16"
  - Type: String

### ASA Configuration Template

If you would like to automate deployment of your ASAv configuration, you can do so by editing the **[asa_config_template.txt](asa_config_template.txt)** file.  This file is deployed to the ASAv instances as their default configuration.
