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
  version = "8.2.1"

  cloud            = "AWS"
  name             = "awsapp1"
  region           = "us-east-1"
  account          = "aws-account"
  transit_gw       = "avx-us-east-1-tg"
  vpc_id           = data.aws_vpc.example.vpc_id
  gw_subnet        = data.aws_subnet.example_gw.cidr_block
  hagw_subnet      = data.aws_subnet.example_hagw.cidr_block #Use separate subnets in multiple AZ's for gw and hagw, for multi AZ availability.
  insane_mode      = true
  use_existing_vpc = true
  inspection       = true

  #Group mode settings 3 GW's, provide the additional subnet CIDR's for spoke gateways 3-n.
  group_mode                    = true
  spoke_gw_amount               = 3
  additional_group_mode_subnets = ["10.1.0.0/26"]
  additional_group_mode_azs     = ["c"]
}
