provider "aws" {}

module "asa-ravpn" {
  source = "github.com/TheAlanNix/terraform-aws-asa-ravpn"
}
