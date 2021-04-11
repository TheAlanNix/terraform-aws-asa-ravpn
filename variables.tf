data "aws_availability_zones" "available" {}

variable "availability_zone_count" {
  type        = number
  default     = 1
  description = "The number of availability zones in which to deploy."
}

variable "instance_size" {
  type        = string
  default     = "c5.2xlarge"
  description = "The desired instance size for the ASAv instances."
}

variable "instances_per_az" {
  type        = number
  default     = 1
  description = "The number of ASAv instances to deploy per availability zone."
}

variable "internal_networks" {
  type = list(string)
  default = [
    "10.0.0.0/8",
    "172.16.0.0/12",
    "192.168.0.0/16"
  ]
  description = "The internal networks that should be accessible to RAVPN clients.  This is used to set up routing and AWS Security Groups."
}

variable "ip_pool_size_bits" {
  type = map(string)
  default = {
    "c5.large"   = 8
    "c5.xlarge"  = 10
    "c5.2xlarge" = 14
  }
  description = "The number of bits that are available as VPN IP pools based on the instance size."
}

variable "ip_pool_size_count" {
  type = map(string)
  default = {
    "c5.large"   = 254
    "c5.xlarge"  = 1022
    "c5.2xlarge" = 16382
  }
  description = "The number of IP addresses that are available to VPN IP pools based on the instance size."
}

variable "smart_account_token" {
  type        = string
  default     = ""
  description = "The Smart Account registration token to use."
}

variable "throughput_level" {
  type = map(string)

  default = {
    "c5.large"   = "1G"
    "c5.xlarge"  = "2G"
    "c5.2xlarge" = "10G"
  }
  description = "The throughput level allowed based on the instance size."
}

variable "vpc_name" {
  type        = string
  default     = "ASAv Remote Access VPN"
  description = "The desired name of the VPC that will be created."
}

variable "vpc_subnet" {
  type        = string
  default     = "10.150.0.0/24"
  description = "The CIDR network that should be used to assign subnets in AWS.  This will be used for interfaces on the ASAv instances."
}

variable "vpn_pool_dns" {
  type        = string
  default     = ""
  description = "A comma-separated list of the default DNS servers to be used by RAVPN clients."
}

variable "vpn_pool_supernet" {
  type        = string
  default     = "10.151.0.0/16"
  description = "The CIDR network that should be used to assign VPN IP pools for RAVPN users."
}
