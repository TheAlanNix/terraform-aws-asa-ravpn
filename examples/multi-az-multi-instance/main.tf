provider "aws" {}

module "asa-ravpn" {
  source = "github.com/TheAlanNix/terraform-aws-asa-ravpn"

  availability_zone_count = 2
  instances_per_az        = 2
}
