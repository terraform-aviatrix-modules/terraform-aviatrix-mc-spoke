### Usage Example GCP Global Spoke

In this example, the spoke_east module deploys a GCP VPC with multiple subnets in different regions. It deploys a pair of spoke gateways in a subnet created in us-east1. The spoke_west module deploys a pair of gateways in the subnet in us-west1, created by the east_spoke module. Also shown in this example are the east and west transit's, transit peering and creating of 2 GCP test instances.

```hcl
module "spoke_east" {
  source  = "terraform-aviatrix-modules/mc-spoke/aviatrix"
  version = "1.7.0"

  cloud             = "GCP"
  name              = "global-spoke-1"
  gw_name           = "east-spoke"
  cidr              = "10.1.0.0/23"
  region            = "us-east1"
  account           = "GCP"
  transit_gw        = module.transit_gcp_east.transit_gateway.gw_name
  enable_global_vpc = true
  additional_gcp_subnets = {
    west-spoke = {
      cidr   = "10.1.2.0/23",
      region = "us-west1",
    }
  }
}

module "spoke_west" {
  source  = "terraform-aviatrix-modules/mc-spoke/aviatrix"
  version = "1.7.0"

  cloud             = "GCP"
  name              = "west-spoke"
  region            = "us-west1"
  account           = "GCP"
  transit_gw        = module.transit_gcp_west.transit_gateway.gw_name
  enable_global_vpc = true

  use_existing_vpc = true
  vpc_id           = module.spoke_east.vpc.vpc_id
  gw_subnet        = module.spoke_east.vpc.subnets[1].cidr
  hagw_subnet      = module.spoke_east.vpc.subnets[1].cidr
}

module "transit_gcp_east" {
  source  = "terraform-aviatrix-modules/mc-transit/aviatrix"
  version = "2.5.0"

  cloud   = "gcp"
  name    = "transit-us-east"
  region  = "us-east1"
  cidr    = "10.2.0.0/23"
  account = "GCP"
}

module "transit_gcp_west" {
  source  = "terraform-aviatrix-modules/mc-transit/aviatrix"
  version = "2.5.0"

  cloud   = "gcp"
  name    = "transit-us-west"
  region  = "us-west1"
  cidr    = "10.2.2.0/23"
  account = "GCP"
}

module "transit-peering" {
  source  = "terraform-aviatrix-modules/mc-transit-peering/aviatrix"
  version = "1.0.8"

  transit_gateways = [
    module.transit_gcp_west.transit_gateway.gw_name,
    module.transit_gcp_east.transit_gateway.gw_name,
  ]

  excluded_cidrs = [
    "0.0.0.0/0",
  ]
}

resource "aviatrix_global_vpc_tagging_settings" "default" {
  service_state = "automatic"
  enable_alert  = true
}

resource "google_compute_instance" "east" {
  name         = "east"
  machine_type = "e2-medium"
  zone         = "us-east1-b"

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-11"
    }
  }

  network_interface {
    subnetwork = "east-spoke"
  }

  depends_on = [
    module.spoke_west
  ]
}

resource "google_compute_instance" "west" {
  name         = "west"
  machine_type = "e2-medium"
  zone         = "us-west1-b"

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-11"
    }
  }

  network_interface {
    subnetwork = "west-spoke"
  }

  depends_on = [
    module.spoke_west
  ]
}

```