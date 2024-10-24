module "spoke_aws_1" {
  source  = "terraform-aviatrix-modules/mc-spoke/aviatrix"
  version = "1.7.0"

  cloud          = "AWS"
  name           = "App1"
  cidr           = "10.1.0.0/20"
  region         = "eu-west-1"
  account        = "AWS-Account"
  transit_gw     = "avx-eu-west-1-transit"
  network_domain = "blue"
  insane_mode    = true

  #Group mode settings 3 GW's, 3 AZ's
  group_mode      = true
  spoke_gw_amount = 3
  additional_group_mode_subnets = [
    cidrsubnet("10.1.0.0/20", 6, pow(2, 6) - 3), #10.1.15.64/26
  ]
  additional_group_mode_azs = [
    "c",
  ]

  #Group mode settings 6 GW's, 3 AZ's
  # group_mode      = true
  # spoke_gw_amount = 6
  # additional_group_mode_subnets = [
  #   cidrsubnet("10.1.0.0/20", 6, pow(2, 6) - 3), #10.1.15.64/26
  #   cidrsubnet("10.1.0.0/20", 6, pow(2, 6) - 4), #10.1.15.0/26
  #   cidrsubnet("10.1.0.0/20", 6, pow(2, 6) - 5), #10.1.14.192/26
  #   cidrsubnet("10.1.0.0/20", 6, pow(2, 6) - 6), #10.1.14.128/26
  # ]
  # additional_group_mode_azs = [
  #   "c",
  # ]


  #Group mode settings 4 GW's, 2 AZ's
  # group_mode      = true
  # spoke_gw_amount = 4
  # additional_group_mode_subnets = [
  #   cidrsubnet("10.1.0.0/20", 6, pow(2, 6) - 3), #10.1.15.64/26
  #   cidrsubnet("10.1.0.0/20", 6, pow(2, 6) - 4), #10.1.15.0/26
  # ]
}
