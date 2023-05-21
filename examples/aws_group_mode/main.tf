module "spoke_aws_1" {
  source  = "terraform-aviatrix-modules/mc-spoke/aviatrix"
  version = "1.6.1"

  cloud          = "AWS"
  name           = "App1"
  cidr           = "10.1.0.0/20"
  region         = "eu-west-1"
  account        = "AWS-Account"
  transit_gw     = "avx-eu-west-1-transit"
  network_domain = "blue"

  #Group mode settings 3 GW's, 3 AZ's
  group_mode      = true
  subnet_pairs    = 3
  spoke_gw_amount = 3

  #Group mode settings 6 GW's, 3 AZ's
  # group_mode      = true
  # subnet_pairs    = 3
  # spoke_gw_amount = 6

  #Group mode settings 4 GW's, 2 AZ's
  # group_mode      = true
  # subnet_pairs    = 2
  # spoke_gw_amount = 4  
}
