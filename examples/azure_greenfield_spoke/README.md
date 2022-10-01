### Usage Example Azure Greenfield Spoke

In this example, the module does not only deploy the Aviatrix spoke gateways, but also creates the VNET itself.

```hcl
module "spoke_azure_1" {
  source  = "terraform-aviatrix-modules/mc-spoke/aviatrix"
  version = "1.3.2"

  cloud           = "Azure"
  name            = "App1"
  cidr            = "10.1.0.0/20"
  region          = "West Europe"
  account         = "Azure-Account"
  transit_gw      = "avx-west-europe-transit"
  security_domain = "green"
}
```