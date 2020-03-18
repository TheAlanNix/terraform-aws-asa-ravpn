data "aws_availability_zones" "available" {}
variable "region" {
  default = "us-east-1"
}
variable "instance_size" {
  default = "c5.2xlarge"
}
variable "availability_zone_count" {
  default = 1
}
variable "internal_networks" {
  default = [
    "10.0.0.0/8",
    "172.16.0.0/12",
    "192.168.0.0/16"
  ]
}
variable "instances_per_az" {
  default = 1
}
variable "transit_gateway_id" {}
variable "vpc_name" {
  default = "ASAv Remote Access VPN"
}
variable "vpc_subnet" {}
