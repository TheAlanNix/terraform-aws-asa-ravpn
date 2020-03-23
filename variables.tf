data "aws_availability_zones" "available" {}
variable "availability_zone_count" {
  default = 1
}
variable "instance_size" {
  default = "c5.2xlarge"
}
variable "instances_per_az" {
  default = 1
}
variable "internal_networks" {
  default = [
    "10.0.0.0/8",
    "172.16.0.0/12",
    "192.168.0.0/16"
  ]
}
variable "ip_pool_size_bits" {
  type = map(string)

  default = {
    "c5.large"   = 8
    "c5.xlarge"  = 10
    "c5.2xlarge" = 14
  }
}
variable "ip_pool_size_count" {
  type = map(string)

  default = {
    "c5.large"   = 254
    "c5.xlarge"  = 1022
    "c5.2xlarge" = 16382
  }
}
variable "region" {
  default = "us-east-1"
}
variable "smart_account_token" {
  default = ""
}
variable "throughput_level" {
  type = map(string)

  default = {
    "c5.large"   = "1G"
    "c5.xlarge"  = "2G"
    "c5.2xlarge" = "10G"
  }
}
variable "vpc_name" {
  default = "ASAv Remote Access VPN"
}
variable "vpc_subnet" {
  default = "10.150.0.0/24"
}
variable "vpn_pool_supernet" {
  default = "10.151.0.0/16"
}
