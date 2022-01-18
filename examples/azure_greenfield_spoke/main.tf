module "spoke_azure_1" {
  source  = "terraform-aviatrix-modules/mc-spoke/aviatrix"
  version = "1.0.1"

  cloud           = "Azure"
  name            = "App1"
  cidr            = "10.1.0.0/20"
  region          = "eu-west-1"
  account         = "Azure-Account"
  transit_gw      = "avx-west-europe-transit"
  security_domain = "green"
}