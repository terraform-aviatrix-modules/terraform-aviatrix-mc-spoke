module "spoke_aws_1" {
  source  = "terraform-aviatrix-modules/mc-spoke/aviatrix"
  version = "8.0.1"

  cloud          = "AWS"
  name           = "App1"
  cidr           = "10.1.0.0/20"
  region         = "eu-west-1"
  account        = "AWS-Account"
  transit_gw     = "avx-eu-west-1-transit"
  network_domain = "blue"
}
