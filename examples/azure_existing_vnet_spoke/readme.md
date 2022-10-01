### Usage Example Azure Existing VPC Spoke

In this example, the module deploys the Aviatrix spoke gateways in an existing VNET.

```hcl
variable "resource_group_name" {
  default = "App1"
}

variable "vnet_name" {
  default = "App1-Spoke-VNET"
}

data "azurerm_virtual_network" "example" {
  name                = var.vnet_name
  resource_group_name = var.resource_group_name
}

data "azurerm_subnet" "example" {
  name                 = "gateway-subnet"
  virtual_network_name = var.vnet_name
  resource_group_name  = var.resource_group_name
}

module "spoke_aws_1" {
  source  = "terraform-aviatrix-modules/mc-spoke/aviatrix"
  version = "1.3.2"

  cloud            = "Azure"
  name             = "App1"
  region           = "West Europe"
  account          = "Azure-Account"
  transit_gw       = "avx-west-europe-transit"
  security_domain  = "green"
  use_existing_vpc = true
  vpc_id           = format("%s:%s", data.azurerm_virtual_network.example.name, data.azurerm_virtual_network.example.resource_group_name)
  gw_subnet        = data.azurerm_subnet.example.address_prefixes[0]
  hagw_subnet      = data.azurerm_subnet.example.address_prefixes[0] #Can be the same subnet, as in Azure subnets stretch AZ's.
}
```