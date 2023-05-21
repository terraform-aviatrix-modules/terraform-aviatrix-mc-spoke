data "aws_vpc" "example" {
  id = var.vpc_id
}

data "aws_subnet" "example_gw" {
  id = var.gw_subnet_id
}

data "aws_subnet" "example_hagw" {
  id = var.hagw_subnet_id
}

module "spoke_aws_1" {
  source  = "terraform-aviatrix-modules/mc-spoke/aviatrix"
  version = "1.6.1"

  cloud          = "AWS"
  name           = "App1"
  region         = "eu-west-1"
  account        = "AWS-Account"
  transit_gw     = "avx-eu-west-1-transit"
  network_domain = "blue"
  vpc_id         = data.aws_vpc.example.vpc_id
  gw_subnet      = data.aws_subnet.example_gw.cidr_block
  hagw_subnet    = data.aws_subnet.example_hagw.cidr_block #Use separate subnets in multiple AZ's for gw and hagw, for multi AZ availability.

  #Group mode settings 3 GW's, provide the additional subnet CIDR's for spoke gateways 3-n.
  group_mode      = true
  spoke_gw_amount = 3
  additional_group_mode_subnets = [
    cidrsubnet("10.1.0.0/20", 6, pow(2, 6) - 3), #10.1.15.64/26
  ]
}
