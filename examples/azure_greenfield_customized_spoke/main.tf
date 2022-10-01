variable "region" {
  default = "West Europe"
}

variable "name" {
  default = "Spoke1"
}

variable "gw_subnet" {
  default = "172.31.1.0/24"
}

variable "vnet_cidr" {
  default = "10.0.0.0/22"
}

resource "azurerm_resource_group" "this" {
  name     = var.name
  location = var.region
}

resource "azurerm_route_table" "this" {
  for_each            = toset(["gateway", "internal1", "internal2", "public1", "public2"])
  name                = "${var.name}-${each.value}"
  location            = var.region
  resource_group_name = azurerm_resource_group.this.name

  #Only add blackhole routes for Internal route tables
  dynamic "route" {
    for_each = can(regex("internal", each.value)) ? ["dummy"] : [] #Trick to make block conditional. Count not available on dynamic blocks.
    content {
      name           = "Blackhole"
      address_prefix = "0.0.0.0/0"
      next_hop_type  = "None"
    }
  }

  lifecycle {
    ignore_changes = [route, ] #Since the Aviatrix controller will maintain the routes, we want to ignore any changes to them in Terraform.
  }
}

module "vnet" {
  source              = "Azure/vnet/azurerm"
  vnet_name           = var.name
  vnet_location       = var.region
  resource_group_name = azurerm_resource_group.this.name
  address_space       = [var.gw_subnet, var.vnet_cidr] #Use a separate CIDR for gateways, to optimize usable IP space for workloads.
  subnet_prefixes = [
    var.gw_subnet,
    cidrsubnet(var.vnet_cidr, 3, 0),
    cidrsubnet(var.vnet_cidr, 3, 1),
    cidrsubnet(var.vnet_cidr, 3, 2),
    cidrsubnet(var.vnet_cidr, 3, 3),
    cidrsubnet(var.vnet_cidr, 3, 4),
    cidrsubnet(var.vnet_cidr, 3, 5),
    cidrsubnet(var.vnet_cidr, 3, 6),
    cidrsubnet(var.vnet_cidr, 3, 7)
  ]
  subnet_names = [
    "AviatrixGateway",
    "Internal1",
    "Internal2",
    "Internal3",
    "Internal4",
    "External1",
    "External2",
    "External3",
    "External4",
  ]

  route_tables_ids = {
    AviatrixGateway = azurerm_route_table.this["gateway"].id
    Internal1       = azurerm_route_table.this["internal1"].id
    Internal2       = azurerm_route_table.this["internal2"].id
    Internal3       = azurerm_route_table.this["internal1"].id
    Internal4       = azurerm_route_table.this["internal2"].id
    External1       = azurerm_route_table.this["public1"].id
    External2       = azurerm_route_table.this["public2"].id
    External3       = azurerm_route_table.this["public1"].id
    External4       = azurerm_route_table.this["public2"].id
  }

  depends_on = [
    azurerm_resource_group.this
  ]
}

module "spoke1_azure" {
  source  = "terraform-aviatrix-modules/mc-spoke/aviatrix"
  version = "1.3.2"

  cloud            = "Azure"
  name             = var.name
  region           = var.region
  account          = "Azure"
  transit_gw       = "avx-west-europe-transit"
  security_domain  = "green"
  use_existing_vpc = true
  vpc_id           = format("%s:%s", module.vnet.vnet_name, azurerm_resource_group.this.name)
  gw_subnet        = var.gw_subnet
  hagw_subnet      = var.gw_subnet #Can be the same subnet, as in Azure subnets stretch AZ's.
}

