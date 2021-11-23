### Usage Example Azure Existing VPC Spoke

In this example, the module deploys the Aviatrix spoke gateways in an existing VNET.

```
module "spoke_aws_1" {
  source  = "terraform-aviatrix-modules/mc-spoke/aviatrix"
  version = "1.0.0"

  cloud            = "Azure"
  name             = "App1"
  cidr             = "10.1.0.0/20"
  region           = "West Europe"
  account          = "Azure-Account"
  transit_gw       = "avx-west-europe-transit"
  security_domain  = "green"
  use_existing_vpc = true
  vpc_id           = "${data.azurerm_virtual_network.example.name}:${data.azurerm_virtual_network.example.resource_group_name}"
  gw_subnet        = data.azurerm_subnet.example.id
  hagw_subnet      = data.azurerm_subnet.example.id #Can be the same subnet, as in Azure subnets stretch AZ's.
}
```