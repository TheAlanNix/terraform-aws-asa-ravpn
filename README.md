# ASAv: Remote Access VPN in AWS

This is a Terraform template meant to quickly configure multiple instances of ASAv in AWS across different availability zones.

## Requirements

* Must have an AWS account.
* Must have Terraform installed. 

## Installation

First, you'll need to have an AWS account, and you'll want to set up configuration and credentials files on your system as outlined in the guide here:

https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-files.html

Once you've configured your AWS credentials file, you'll need to install Terraform.  If you've never used Terraform before, they provide detailed documentation and tutorials here:

https://learn.hashicorp.com/terraform#getting-started

Once Terraform is installed, and your AWS credentials file is configured, you'll want to edit the ***[terraform.tfvars](terraform.tfvars)*** file to specify configuration for your ASAv-RAVPN deployment.
