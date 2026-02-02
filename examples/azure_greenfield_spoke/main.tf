module "spoke_azure_1" {
  source  = "terraform-aviatrix-modules/mc-spoke/aviatrix"
  version = "8.2.1"

  cloud          = "Azure"
  name           = "App1"
  cidr           = "10.1.0.0/20"
  region         = "West Europe"
  account        = "Azure-Account"
  transit_gw     = "avx-west-europe-transit"
  network_domain = "green"
}
