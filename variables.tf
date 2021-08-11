variable "cloud" {
  description = "Cloud type"
  type        = string

  validation {
    condition     = contains(["aws", "azure", "oci", "ali", "gcp"], lower(var.cloud))
    error_message = "Invalid cloud type. Choose AWS, Azure, GCP, ALI or OCI."
  }
}

variable "name" {
  description = "Name for this spoke VPC and it's gateways"
  type        = string
}

variable "prefix" {
  description = "Boolean to determine if name will be prepended with avx-"
  type        = bool
  default     = true
}

variable "suffix" {
  description = "Boolean to determine if name will be appended with -spoke"
  type        = bool
  default     = true
}

variable "region" {
  description = "The region to deploy this module in"
  type        = string
}

variable "ha_region" {
  description = "Secondary GCP region where subnet and HA Aviatrix Spoke Gateway will be created"
  type        = string
  default     = ""
}

variable "cidr" {
  description = "The CIDR range to be used for the VPC"
  type        = string
  default     = ""
}

variable "ha_cidr" {
  description = "CIDR of the HA GCP subnet"
  type        = string
  default     = ""
}

variable "account" {
  description = "The AWS account name, as known by the Aviatrix controller"
  type        = string
}

variable "instance_size" {
  description = "Instance size for the Aviatrix gateways"
  type        = string
  default     = ""
}

variable "ha_gw" {
  description = "Boolean to determine if module will be deployed in HA or single mode"
  type        = bool
  default     = true
}

variable "insane_mode" {
  description = "Set to true to enable Aviatrix high performance encryption."
  type        = bool
  default     = false

  # validation {
  #   condition     = !contains(["aws", "azure", "oci", "gcp"], lower(var.cloud)) ? (var.insane_mode ? true : false) : true
  #   error_message = "Insane mode not supported for ${var.cloud}"
  # }
}

variable "az1" {
  description = "Concatenates with region to form az names. e.g. eu-central-1a. Only used for insane mode"
  type        = string
  default     = ""
}

variable "az2" {
  description = "Concatenates with region to form az names. e.g. eu-central-1b. Only used for insane mode"
  type        = string
  default     = ""
}

variable "az_support" {
  description = "Set to true if the Azure region supports AZ's"
  type        = bool
  default     = true
}

variable "transit_gw" {
  description = "Name of the transit gateway to attach this spoke to"
  type        = string
  default     = ""
}

variable "transit_gw_egress" {
  description = "Name of the transit gateway to attach this spoke to"
  type        = string
  default     = ""
}

variable "transit_gw_route_tables" {
  description = "Route tables to propagate routes to for transit_gw attachment"
  type        = list(string)
  default     = []
}

variable "transit_gw_egress_route_tables" {
  description = "Route tables to propagate routes to for transit_gw_egress attachment"
  type        = list(string)
  default     = []
}

variable "active_mesh" {
  description = "Set to false to disable active mesh."
  type        = bool
  default     = true
}

variable "attached" {
  description = "Set to false if you don't want to attach spoke to transit_gw."
  type        = bool
  default     = true
}

variable "attached_gw_egress" {
  description = "Set to false if you don't want to attach spoke to transit_gw2."
  type        = bool
  default     = true
}

variable "security_domain" {
  description = "Provide security domain name to which spoke needs to be deployed. Transit gateway mus tbe attached and have segmentation enabled."
  type        = string
  default     = ""
}

variable "single_az_ha" {
  description = "Set to true if Controller managed Gateway HA is desired"
  type        = bool
  default     = true
}

variable "single_ip_snat" {
  description = "Specify whether to enable Source NAT feature in single_ip mode on the gateway or not. Please disable AWS NAT instance before enabling this feature. Currently only supports AWS(1) and AZURE(8). Valid values: true, false."
  type        = bool
  default     = false
}

variable "customized_spoke_vpc_routes" {
  description = "A list of comma separated CIDRs to be customized for the spoke VPC routes. When configured, it will replace all learned routes in VPC routing tables, including RFC1918 and non-RFC1918 CIDRs. It applies to this spoke gateway only​. Example: 10.0.0.0/116,10.2.0.0/16"
  type        = string
  default     = ""
}

variable "filtered_spoke_vpc_routes" {
  description = "A list of comma separated CIDRs to be filtered from the spoke VPC route table. When configured, filtering CIDR(s) or it’s subnet will be deleted from VPC routing tables as well as from spoke gateway’s routing table. It applies to this spoke gateway only. Example: 10.2.0.0/116,10.3.0.0/16"
  type        = string
  default     = ""
}

variable "included_advertised_spoke_routes" {
  description = "A list of comma separated CIDRs to be advertised to on-prem as Included CIDR List. When configured, it will replace all advertised routes from this VPC. Example: 10.4.0.0/116,10.5.0.0/16"
  type        = string
  default     = ""
}

variable "subnet_pairs" {
  description = "Number of subnet pairs created in the VPC"
  type        = number
  default     = 0
}

variable "subnet_size" {
  description = "Size of each subnet cidr block in bits"
  type        = number
  default     = 0
}

variable "enable_encrypt_volume" {
  description = "Enable EBS volume encryption for Gateway. Only supports AWS and AWSGOV provider. Valid values: true, false. Default value: false"
  type        = bool
  default     = false
}

variable "customer_managed_keys" {
  description = "Customer managed key ID for EBS Volume encryption."
  type        = string
  default     = null
}

variable "private_vpc_default_route" {
  description = "Program default route in VPC private route table."
  type        = bool
  default     = false
}

variable "skip_public_route_table_update" {
  description = "Skip programming VPC public route table."
  type        = bool
  default     = false
}

variable "auto_advertise_s2c_cidrs" {
  description = "Auto Advertise Spoke Site2Cloud CIDRs."
  type        = bool
  default     = false
}

variable "tunnel_detection_time" {
  description = "The IPsec tunnel down detection time for the Spoke Gateway in seconds. Must be a number in the range [20-600]."
  type        = number
  default     = null
}

variable "tags" {
  description = "Map of tags to assign to the gateway."
  type        = map(string)
  default     = null
}

variable "use_existing_vpc" {
  description = "Set to true to use existing VPC."
  type        = bool
  default     = false
}

variable "vpc_id" {
  description = "VPC ID, for using an existing VPC."
  type        = string
  default     = ""
}

variable "gw_subnet" {
  description = "Subnet CIDR, for using an existing VPC. Required when use_existing_vpc is true"
  type        = string
  default     = ""
}

variable "hagw_subnet" {
  description = "Subnet CIDR, for using an existing VPC. Required when use_existing_vpc is true and ha_gw is true"
  type        = string
  default     = ""
}

variable "china" {
  description = "Set to true if deploying this module in AWS/Azure China."
  type        = bool
  default     = false
}

variable "gov" {
  description = "Set to true if deploying this module in AWS GOV."
  type        = bool
  default     = false
}

variable "resource_group" {
  description = "Provide the name of an existing resource group."
  type        = string
  default     = null
}

variable "inspection" {
  description = "Set to true to enable east/west Firenet inspection. Only valid when transit_gw is East/West transit Firenet"
  type        = bool
  default     = false
}

locals {
  cloud = lower(var.cloud)

  prefix     = var.prefix ? "avx-" : ""
  suffix     = var.suffix ? "-spoke" : ""
  lower_name = replace(lower(var.name), " ", "-")
  name       = "${local.prefix}${local.lower_name}${local.suffix}"

  cidr                  = var.use_existing_vpc ? "10.0.0.0/20" : var.cidr #Set dummy if existing VPC is used.
  cidrbits              = tonumber(split("/", local.cidr)[1])
  newbits               = 26 - local.cidrbits
  netnum                = pow(2, local.newbits)
  insane_mode_subnet    = cidrsubnet(local.cidr, local.newbits, local.netnum - 2)
  ha_insane_mode_subnet = cidrsubnet(local.cidr, local.newbits, local.netnum - 1)

  az1 = length(var.az1) > 0 ? var.az1 : lookup(local.az1_map, local.cloud, null)
  az1_map = {
    azure = var.az_support ? "az-1" : null,
    aws   = "a",
    gcp   = "b",
  }

  az2 = length(var.az2) > 0 ? var.az2 : lookup(local.az2_map, local.cloud, null)
  az2_map = {
    azure = var.az_support ? "az-2" : null,
    aws   = "b",
    gcp   = "c",
  }

  subnet = var.use_existing_vpc ? var.gw_subnet : (var.insane_mode ? local.insane_mode_subnet : (local.cloud == "gcp" ? aviatrix_vpc.default[0].subnets[local.subnet_map[local.cloud]].cidr : aviatrix_vpc.default[0].public_subnets[local.subnet_map[local.cloud]].cidr))
  subnet_map = {
    azure = 0,
    aws   = 0,
    gcp   = 0,
    oci   = 0,
    ali   = 0,
  }

  ha_subnet = var.use_existing_vpc ? (contains(["azure", "oci"], local.cloud) ? var.gw_subnet : var.hagw_subnet) : (var.insane_mode ? local.ha_insane_mode_subnet : (local.cloud == "gcp" ? aviatrix_vpc.default[0].subnets[local.ha_subnet_map[local.cloud]].cidr : aviatrix_vpc.default[0].public_subnets[local.ha_subnet_map[local.cloud]].cidr))
  ha_subnet_map = {
    azure = 0,
    aws   = 1,
    gcp   = length(var.ha_region) > 0 ? 1 : 0
    oci   = 0,
    ali   = 1,
  }

  insane_mode_az = var.insane_mode ? lookup(local.ha_subnet_map, local.cloud, null) : null
  insane_mode_az_map = {
    aws = "${var.region}${var.az1}",
  }

  ha_insane_mode_az = var.insane_mode ? lookup(local.ha_subnet_map, local.cloud, null) : null
  ha_insane_mode_az_map = {
    aws = "${var.region}${var.az2}",
  }

  cloud_type = var.china ? lookup(local.cloud_type_map_china, local.cloud, null) : (var.gov ? lookup(local.cloud_type_map_gov, local.cloud, null) : lookup(local.cloud_type_map, local.cloud, null))
  cloud_type_map = {
    azure = 8,
    aws   = 1,
    gcp   = 4,
    oci   = 16,
    ali   = 8192,
  }

  cloud_type_map_china = {
    azure = 2048,
    aws   = 1024,
  }

  cloud_type_map_gov = {
    aws = 256,
  }

  instance_size = length(var.instance_size) > 0 ? var.instance_size : lookup(local.instance_size_map, local.cloud, null)
  instance_size_map = {
    azure = "Standard_B1ms",
    aws   = "t3.medium",
    gcp   = "n1-standard-1",
    oci   = "VM.Standard2.2",
    ali   = "ecs.g5ne.large",
  }

  subnet_pairs = var.subnet_pairs != 0 ? var.subnet_pairs : lookup(local.subnet_pairs_map, local.cloud, null)
  subnet_pairs_map = {
    azure = 2,
    aws   = 2,
  }

  subnet_size = var.subnet_size != 0 ? var.subnet_size : lookup(local.subnet_size_map, local.cloud, null)
  subnet_size_map = {
    azure = 28,
    aws   = 28,
  }
}
