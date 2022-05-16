terraform {
  required_providers {
    test = {
      source = "terraform.io/builtin/test"
    }
    aviatrix = {
      source = "aviatrixsystems/aviatrix"
    }
  }
}

provider "aviatrix" {}

module "ali_non_ha_spoke" {
  source = "../.."

  cloud    = "ali"
  name     = "spoke-non-ha-ali"
  region   = "acs-eu-central-1 (Frankfurt)"
  cidr     = "10.1.101.0/24"
  account  = "ALI"
  attached = false
  ha_gw    = false
}

module "ali_ha_spoke" {
  source = "../.."

  cloud    = "ali"
  name     = "spoke-ha-ali"
  region   = "acs-eu-central-1 (Frankfurt)"
  cidr     = "10.1.102.0/24"
  account  = "ALI"
  attached = false
}

resource "test_assertions" "cloud_type_non_ha" {
  component = "cloud_type_non_ha"

  equal "cloud_type_non_ha" {
    description = "Module output is equal to check map."
    got         = module.ali_non_ha_spoke.spoke_gateway.cloud_type
    want        = 8192
  }
}

resource "test_assertions" "cloud_type_ha" {
  component = "cloud_type_ha"

  equal "cloud_type_ha" {
    description = "Module output is equal to check map."
    got         = module.ali_ha_spoke.spoke_gateway.cloud_type
    want        = 8192
  }
}
