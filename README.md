# ASAv: Remote Access VPN in AWS

This is a Terraform Module meant to quickly configure multiple Cisco ASAv instances for remote-access VPN (RAVPN), across multiple availability zones, in AWS.

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

## Using the Terraform Module

To apply this template, follow the steps below:

1. Understand what an AWS Transit Gateway is, and why it is used.
    - Decide whether you want to create a new Transit Gateway, or leverage an existing one.
2. Import this module and supply the appropriate input variables.
    - Input variables and their default values are described below.
3. Initialize Terraform by running `terraform init` from the root directory of this repository.
4. Verify the Terraform configuration by running `terraform plan` to preview the changes that will be made.
5. Once verified, simply run `terraform apply` to deploy your RAVPN infrastructure.
6. During deployment, a password.txt file will be created in the root directory of the repository which contains a 40-character random password for the 'admin' account on the ASAv instances.  This is also used for the enable password.
7. When deployment is complete, you can access the management or inside interfaces of the ASAv by default.  It's also possible to connect to the outside IP address, but you must manually edit the AWS Security Group to allow SSH/HTTPS in order to do so.

## AWS Transit Gateway

This script will leverage an AWS Transit Gateway to tunnel traffic to/from the created AWS VPC to your networks.  High-level design of AWS Site-to-Site VPN designs, including Transit Gateways, can be found here:

https://docs.aws.amazon.com/vpn/latest/s2svpn/how_it_works.html#Transit-Gateway

### Option 1: Create a new Transit Gateway

The default configuration will create a new Transit Gateway and build the appropriate route tables.  You will then need to create a Customer Gateway and configure your Site-to-Site VPN tunnel(s) to AWS in order to allow RAVPN users to access internal resources.

### Option 2: Leverage an existing Transit Gateway

You can leverage an existing AWS Transit Gateway by importing it into Terraform's "state" by running the following command:

`terraform import module.<module_name>.aws_ec2_transit_gateway.transit_gateway <Transit_Gateway_ID>`

Upon importing an existing Transit Gateway, you'll want to verify the `terraform plan` data to make sure that it is simply going to modify the existing Transit Gateway, rather than re-creating it.  This may mean you need to manually sync things like name/description.

Also, prior to running a `terraform destroy` you'll want to remove the existing transit gateway to prevent it from being destroyed.  If there are existing attachments to the Transit Gateway, it should prevent deletion - but better safe than sorry.  To remove the existing Transit Gateway from Terraform, simply run the following command:

`terraform state rm module.<module_name>.aws_ec2_transit_gateway.transit_gateway`

For more information on Transit Gateways, please see Amazon's full documentation here:

https://docs.aws.amazon.com/vpc/latest/tgw/tgw-transit-gateways.html

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_availability_zone_count"></a> [availability\_zone\_count](#input\_availability\_zone\_count) | The number of availability zones in which to deploy. | `number` | `1` | no |
| <a name="input_instance_size"></a> [instance\_size](#input\_instance\_size) | The desired instance size for the ASAv instances. | `string` | `"c5.2xlarge"` | no |
| <a name="input_instances_per_az"></a> [instances\_per\_az](#input\_instances\_per\_az) | The number of ASAv instances to deploy per availability zone. | `number` | `1` | no |
| <a name="input_internal_networks"></a> [internal\_networks](#input\_internal\_networks) | The internal networks that should be accessible to RAVPN clients.  This is used to set up routing and AWS Security Groups. | `list(string)` | <pre>[<br>  "10.0.0.0/8",<br>  "172.16.0.0/12",<br>  "192.168.0.0/16"<br>]</pre> | no |
| <a name="input_ip_pool_size_bits"></a> [ip\_pool\_size\_bits](#input\_ip\_pool\_size\_bits) | The number of bits that are available as VPN IP pools based on the instance size. | `map(string)` | <pre>{<br>  "c5.2xlarge": 14,<br>  "c5.large": 8,<br>  "c5.xlarge": 10<br>}</pre> | no |
| <a name="input_ip_pool_size_count"></a> [ip\_pool\_size\_count](#input\_ip\_pool\_size\_count) | The number of IP addresses that are available to VPN IP pools based on the instance size. | `map(string)` | <pre>{<br>  "c5.2xlarge": 16382,<br>  "c5.large": 254,<br>  "c5.xlarge": 1022<br>}</pre> | no |
| <a name="input_smart_account_token"></a> [smart\_account\_token](#input\_smart\_account\_token) | The Smart Account registration token to use. | `string` | `""` | no |
| <a name="input_throughput_level"></a> [throughput\_level](#input\_throughput\_level) | The throughput level allowed based on the instance size. | `map(string)` | <pre>{<br>  "c5.2xlarge": "10G",<br>  "c5.large": "1G",<br>  "c5.xlarge": "2G"<br>}</pre> | no |
| <a name="input_vpc_name"></a> [vpc\_name](#input\_vpc\_name) | The desired name of the VPC that will be created. | `string` | `"ASAv Remote Access VPN"` | no |
| <a name="input_vpc_subnet"></a> [vpc\_subnet](#input\_vpc\_subnet) | The CIDR network that should be used to assign subnets in AWS.  This will be used for interfaces on the ASAv instances. | `string` | `"10.150.0.0/24"` | no |
| <a name="input_vpn_pool_dns"></a> [vpn\_pool\_dns](#input\_vpn\_pool\_dns) | A comma-separated list of the default DNS servers to be used by RAVPN clients. | `string` | `""` | no |
| <a name="input_vpn_pool_supernet"></a> [vpn\_pool\_supernet](#input\_vpn\_pool\_supernet) | The CIDR network that should be used to assign VPN IP pools for RAVPN users. | `string` | `"10.151.0.0/16"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_inside_ips"></a> [inside\_ips](#output\_inside\_ips) | The IPs of the 'inside' interfaces of the ASAv appliances. |
| <a name="output_management_ips"></a> [management\_ips](#output\_management\_ips) | The IPs of the 'management' interfaces of the ASAv appliances. |
| <a name="output_outside_ips"></a> [outside\_ips](#output\_outside\_ips) | The IPs of the 'outside' interfaces of the ASAv appliances. |

## ASA Configuration Template

If you would like to automate deployment of your ASAv configuration, you can do so by editing the **[asa_config_template.txt](asa_config_template.txt)** file.  This file is deployed to the ASAv instances as their default configuration.
