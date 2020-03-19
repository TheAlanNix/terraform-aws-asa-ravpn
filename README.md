# ASAv: Remote Access VPN in AWS

This is a Terraform template meant to quickly configure multiple Cisco ASAv instances, across multiple availability zones, in AWS.

## Requirements

1. Must have an AWS account.
2. Must have Terraform installed. 

## Installation

First, you'll need to have an AWS account, and you'll want to set up configuration and credentials files on your system as outlined in the guide here:

https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-files.html

This script will leverage an AWS Transit Gateway to tunnel traffic to/from the created AWS VPC to other networks.  You can leverage an existing AWS Transit Gateway by adding the Transit Gateway's ID as a variable, otherwise a new Transit Gateway will be created for you.  For more information on Transit Gateways, please see Amazon's documentation here:

https://docs.aws.amazon.com/vpc/latest/tgw/tgw-transit-gateways.html

Once you've configured your AWS credentials file, you'll need to install Terraform.  If you've never used Terraform before, they provide detailed documentation and tutorials here:

https://learn.hashicorp.com/terraform#getting-started

Once your environment is set up, you'll want to edit the **[terraform.tfvars](terraform.tfvars)** file in this repository to specify configuration for your ASAv-RAVPN deployment.  Configuration variables are as follows:

- availability_zone_count:  The number of availability zones in which to deploy.
  - Default: 1
  - Type: Integer
- instance_size:  The desired instance size for the ASAv instances.
  - Default: "c5.2xlarge"
  - Type: String
  - Values: c5.large / c5.xlarge / c5.2xlarge
- instances_per_az:  The number of ASAv instances per availability zone.
  - Default: 1
  - Type: Integer
- internal_networks:  The internal networks that should be accessible by RAVPN clients.  This is used to set up routing and AWS Security Groups.
  - Default: ["10.0.0.0/8", "172.16.0.0/12", "192.168.0.0/16"]
  - Type: List of CIDR networks
- region:  The AWS Region that you'd like to deploy to.
  - Default: "us-east-1"
  - Type: String
- smart_account_token:  (Optional) The Smart License Registration Token that you would like to use.
  - Default: ""
  - Type: String
- transit_gateway_id:  (Optional) The ID of the transit gateway to attach to.
  - Default: ""
  - Type: String
- vpc_name:  The desired name of the VPC that will be created.
  - Default: "ASAv Remote Access VPN"
  - Type: String
- vpc_subnet:  **[REQUIRED]** The CIDR network that should be used to assign subnets in AWS.
  - Default: ""
  - Type: String
