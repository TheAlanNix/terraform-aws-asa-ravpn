# Multi Availability Zone ASAv RAVPN Configuration

```hcl
provider "aws" {}

module "asa-ravpn" {
  source = "github.com/TheAlanNix/terraform-aws-asa-ravpn"

  availability_zone_count = 2
}
```