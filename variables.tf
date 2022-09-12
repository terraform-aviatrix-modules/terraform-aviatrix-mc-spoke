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

  validation {
    condition     = length(var.name) <= 50
    error_message = "Name is too long. Max length is 50 characters."
  }
}

variable "gw_name" {
  description = "Name for the spoke gateway"
  type        = string
  default     = ""
  nullable    = false

  validation {
    condition     = length(var.gw_name) <= 50
    error_message = "Name is too long. Max length is 50 characters."
  }

  validation {
    condition     = can(regex("^[a-zA-Z0-9-_]*$", var.gw_name))
    error_message = "Only a-z, A-Z, 0-9 and hyphens and underscores are allowed."
  }
}

variable "region" {
  description = "The region to deploy this module in"
  type        = string
}

variable "ha_region" {
  description = "Secondary GCP region where subnet and HA Aviatrix Spoke Gateway will be created"
  type        = string
  default     = ""
  nullable    = false
}

variable "cidr" {
  description = "The CIDR range to be used for the VPC"
  type        = string
  default     = ""
  nullable    = false

  validation {
    condition     = var.cidr != "" ? can(cidrnetmask(var.cidr)) : true
    error_message = "This does not like a valid CIDR."
  }
}

variable "ha_cidr" {
  description = "CIDR of the HA GCP subnet"
  type        = string
  default     = ""
  nullable    = false

  validation {
    condition     = var.ha_cidr != "" ? can(cidrnetmask(var.ha_cidr)) : true
    error_message = "This does not like a valid CIDR."
  }
}

variable "account" {
  description = "The AWS account name, as known by the Aviatrix controller"
  type        = string
}

variable "instance_size" {
  description = "Instance size for the Aviatrix gateways"
  type        = string
  default     = ""
  nullable    = false
}

variable "ha_gw" {
  description = "Boolean to determine if module will be deployed in HA or single mode"
  type        = bool
  default     = true
  nullable    = false
}

variable "insane_mode" {
  description = "Set to true to enable Aviatrix high performance encryption."
  type        = bool
  default     = false
  nullable    = false
}

variable "az1" {
  description = "Concatenates with region to form az names. e.g. eu-central-1a. Only used for insane mode"
  type        = string
  default     = ""
  nullable    = false
}

variable "az2" {
  description = "Concatenates with region to form az names. e.g. eu-central-1b. Only used for insane mode"
  type        = string
  default     = ""
  nullable    = false
}

variable "az_support" {
  description = "Set to true if the Azure region supports AZ's"
  type        = bool
  default     = true
  nullable    = false
}

variable "transit_gw" {
  description = "Name of the transit gateway to attach this spoke to"
  type        = string
  default     = ""
  nullable    = false
}

variable "transit_gw_egress" {
  description = "Name of the transit gateway to attach this spoke to"
  type        = string
  default     = ""
  nullable    = false
}

variable "transit_gw_route_tables" {
  description = "Route tables to propagate routes to for transit_gw attachment"
  type        = list(string)
  default     = []
  nullable    = false
}

variable "transit_gw_egress_route_tables" {
  description = "Route tables to propagate routes to for transit_gw_egress attachment"
  type        = list(string)
  default     = []
  nullable    = false
}

variable "attached" {
  description = "Set to false if you don't want to attach spoke to transit_gw."
  type        = bool
  default     = true
  nullable    = false
}

variable "attached_gw_egress" {
  description = "Set to false if you don't want to attach spoke to transit_gw2."
  type        = bool
  default     = true
  nullable    = false
}

variable "network_domain" {
  description = "Provide network domain name to which spoke needs to be deployed. Transit gateway must be attached and have segmentation enabled."
  type        = string
  default     = ""
  nullable    = false
}

variable "single_az_ha" {
  description = "Set to true if Controller managed Gateway HA is desired"
  type        = bool
  default     = true
  nullable    = false
}

variable "single_ip_snat" {
  description = "Specify whether to enable Source NAT feature in single_ip mode on the gateway or not. Please disable AWS NAT instance before enabling this feature. Currently only supports AWS(1) and AZURE(8). Valid values: true, false."
  type        = bool
  default     = false
  nullable    = false
}

variable "customized_spoke_vpc_routes" {
  description = "A list of comma separated CIDRs to be customized for the spoke VPC routes. When configured, it will replace all learned routes in VPC routing tables, including RFC1918 and non-RFC1918 CIDRs. It applies to this spoke gateway only​. Example: 10.0.0.0/116,10.2.0.0/16"
  type        = string
  default     = ""
  nullable    = false
}

variable "filtered_spoke_vpc_routes" {
  description = "A list of comma separated CIDRs to be filtered from the spoke VPC route table. When configured, filtering CIDR(s) or it’s subnet will be deleted from VPC routing tables as well as from spoke gateway’s routing table. It applies to this spoke gateway only. Example: 10.2.0.0/116,10.3.0.0/16"
  type        = string
  default     = ""
  nullable    = false
}

variable "included_advertised_spoke_routes" {
  description = "A list of comma separated CIDRs to be advertised to on-prem as Included CIDR List. When configured, it will replace all advertised routes from this VPC. Example: 10.4.0.0/116,10.5.0.0/16"
  type        = string
  default     = ""
  nullable    = false
}

variable "subnet_pairs" {
  description = "Number of subnet pairs created in the VPC"
  type        = number
  default     = null
}

variable "subnet_size" {
  description = "Size of each subnet cidr block in bits"
  type        = number
  default     = null
}

variable "enable_encrypt_volume" {
  description = "Enable EBS volume encryption for Gateway. Only supports AWS and AWSGOV provider. Valid values: true, false. Default value: false"
  type        = bool
  default     = false
  nullable    = false
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
  nullable    = false
}

variable "skip_public_route_table_update" {
  description = "Skip programming VPC public route table."
  type        = bool
  default     = false
  nullable    = false
}

variable "auto_advertise_s2c_cidrs" {
  description = "Auto Advertise Spoke Site2Cloud CIDRs."
  type        = bool
  default     = false
  nullable    = false
}

variable "tunnel_detection_time" {
  description = "The IPsec tunnel down detection time for the Spoke Gateway in seconds. Must be a number in the range [20-600]."
  type        = number
  default     = null

  validation {
    condition     = var.tunnel_detection_time != null ? (var.tunnel_detection_time >= 20 && var.tunnel_detection_time <= 600) : true
    error_message = "Invalid value. Must be in range 20-600."
  }
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
  nullable    = false
}

variable "vpc_id" {
  description = "VPC ID, for using an existing VPC."
  type        = string
  default     = ""
  nullable    = false
}

variable "gw_subnet" {
  description = "Subnet CIDR, for using an existing VPC. Required when use_existing_vpc is true"
  type        = string
  default     = ""
  nullable    = false

  validation {
    condition     = var.gw_subnet != "" ? can(cidrnetmask(var.gw_subnet)) : true
    error_message = "This does not like a valid CIDR."
  }
}

variable "hagw_subnet" {
  description = "Subnet CIDR, for using an existing VPC. Required when use_existing_vpc is true and ha_gw is true"
  type        = string
  default     = ""
  nullable    = false

  validation {
    condition     = var.hagw_subnet != "" ? can(cidrnetmask(var.hagw_subnet)) : true
    error_message = "This does not like a valid CIDR."
  }
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
  nullable    = false
}

variable "enable_bgp" {
  description = "Enable BGP for this spoke gateway."
  type        = bool
  default     = false
  nullable    = false
}

variable "spoke_bgp_manual_advertise_cidrs" {
  description = "Intended CIDR list to be advertised to external BGP router."
  type        = list(string)
  default     = null
}

variable "bgp_ecmp" {
  description = "Enable Equal Cost Multi Path (ECMP) routing"
  type        = bool
  default     = false
  nullable    = false
}

variable "enable_active_standby" {
  description = "Enables Active-Standby Mode. Available only with HA enabled."
  type        = bool
  default     = false
  nullable    = false
}

variable "prepend_as_path" {
  description = "List of AS numbers to populate BGP AS_PATH field when it advertises to VGW or peer devices."
  type        = list(number)
  default     = null
}

variable "bgp_polling_time" {
  description = "BGP route polling time. Unit is in seconds."
  type        = number
  default     = null

  validation {
    condition     = var.bgp_polling_time != null ? (var.bgp_polling_time >= 10 && var.bgp_polling_time <= 50) : true
    error_message = "Invalid value. Must be in range 10-50."
  }
}

variable "bgp_hold_time" {
  description = "BGP hold time. Unit is in seconds."
  type        = number
  default     = null

  validation {
    condition     = var.bgp_hold_time != null ? (var.bgp_hold_time >= 12 && var.bgp_hold_time <= 360) : true
    error_message = "Invalid value. Must be in range 12-360."
  }
}

variable "enable_learned_cidrs_approval" {
  description = "Switch to enable/disable CIDR approval for BGP Spoke Gateway."
  type        = bool
  default     = false
  nullable    = false
}

variable "learned_cidrs_approval_mode" {
  description = "Learned CIDRs approval mode. Either \"gateway\" (approval on a per-gateway basis) or \"connection\" (approval on a per-connection basis)."
  type        = string
  default     = null

  validation {
    condition     = var.learned_cidrs_approval_mode != null ? contains(["connection", "gateway"], lower(var.learned_cidrs_approval_mode)) : true
    error_message = "Invalid approval mode. Choose connection or gateway."
  }
}

variable "approved_learned_cidrs" {
  description = "A list of approved learned CIDRs."
  type        = list(string)
  default     = null
}

variable "local_as_number" {
  description = "Changes the Aviatrix Spoke Gateway ASN number before you setup Aviatrix Spoke Gateway connection configurations."
  type        = number
  default     = null
}

variable "subnet_groups" {
  description = "Map of subnet groups to create for this spoke."
  type        = map(any)
  default     = {}
  nullable    = false
}

variable "rx_queue_size" {
  description = "Gateway ethernet interface RX queue size. Once set, can't be deleted or disabled."
  type        = string
  default     = null

  validation {
    condition     = var.rx_queue_size != null ? contains(["1K", "2K", "4K", "8K", "16K"], var.rx_queue_size) : true
    error_message = "Expected rx_queue_size to be one of [1K 2K 4K 8K 16K]."
  }
}

variable "availability_domain" {
  description = "Availability domain in OCI."
  type        = string
  default     = null
}

variable "ha_availability_domain" {
  description = "Availability domain in OCI for HA GW."
  type        = string
  default     = null
}

variable "fault_domain" {
  description = "Fault domain in OCI."
  type        = string
  default     = null
}

variable "ha_fault_domain" {
  description = "Fault domain in OCI for HA GW."
  type        = string
  default     = null
}

variable "enable_preserve_as_path" {
  description = "Enable preserve as_path when advertising manual summary cidrs on BGP spoke gateway."
  type        = bool
  default     = null
}

variable "private_mode_lb_vpc_id" {
  description = "VPC ID of Private Mode load balancer. Required when Private Mode is enabled on the Controller."
  type        = string
  default     = null
}

variable "enable_max_performance" {
  description = "Indicates whether the maximum amount of HPE tunnels will be created. Only valid when transit and spoke gateways are each launched in Insane Mode and in the same cloud type."
  type        = bool
  default     = null
}

variable "private_mode_subnets" {
  description = "Switch to only launch private subnets. Only available when Private Mode is enabled on the Controller."
  type        = bool
  default     = false
  nullable    = false
}

variable "spoke_prepend_as_path" {
  description = "Connection based AS Path Prepend."
  type        = list(string)
  default     = null
}

variable "transit_prepend_as_path" {
  description = "Connection based AS Path Prepend."
  type        = list(string)
  default     = null
}

locals {
  cloud                 = lower(var.cloud)
  name                  = replace(var.name, " ", "-") #Replace spaces with dash
  gw_name               = coalesce(var.gw_name, local.name)
  cidr                  = var.use_existing_vpc ? "10.0.0.0/20" : var.cidr #Set dummy if existing VPC is used.
  cidrbits              = tonumber(split("/", local.cidr)[1])
  newbits               = 26 - local.cidrbits
  netnum                = pow(2, local.newbits)
  insane_mode_subnet    = var.insane_mode || var.private_mode_subnets ? cidrsubnet(local.cidr, local.newbits, local.netnum - 2) : null #Only calculate if insane_mode is true
  ha_insane_mode_subnet = var.insane_mode || var.private_mode_subnets ? cidrsubnet(local.cidr, local.newbits, local.netnum - 1) : null #Only calculate if insane_mode is true

  #Auto disable AZ support for gov and dod regions in Azure
  az_support = local.is_gov ? false : var.az_support

  az1 = length(var.az1) > 0 ? var.az1 : lookup(local.az1_map, local.cloud, null)
  az1_map = {
    azure = local.az_support ? "az-1" : null,
    aws   = "a",
    gcp   = "b",
  }

  az2 = length(var.az2) > 0 ? var.az2 : lookup(local.az2_map, local.cloud, null)
  az2_map = {
    azure = local.az_support ? "az-2" : null,
    aws   = "b",
    gcp   = "c",
  }

  subnet = (var.use_existing_vpc ?
    var.gw_subnet
    :
    ((var.insane_mode && contains(["aws", "azure", "oci"], local.cloud)) || (var.private_mode_subnets && contains(["aws", "azure"], local.cloud)) ?
      local.insane_mode_subnet
      :
      (local.cloud == "gcp" ?
        aviatrix_vpc.default[0].subnets[local.subnet_map[local.cloud]].cidr
        :
        aviatrix_vpc.default[0].public_subnets[local.subnet_map[local.cloud]].cidr
      )
    )
  )

  subnet_map = {
    azure = 0,
    aws   = 0,
    gcp   = 0,
    oci   = 0,
    ali   = 0,
  }

  ha_subnet = (var.use_existing_vpc ?
    (contains(["azure", "oci"], local.cloud) && var.hagw_subnet == "" ? #If HAGW Subnet is not provided, use gw_subnet. This is acceptable for Azure and OCI, because a subnet can stretch AZ's/Fault domains.
      var.gw_subnet
      :
      var.hagw_subnet
    )
    :
    ((var.insane_mode && contains(["aws", "azure", "oci"], local.cloud)) || (var.private_mode_subnets && contains(["aws", "azure"], local.cloud)) ?
      local.ha_insane_mode_subnet
      :
      (local.cloud == "gcp" ?
        aviatrix_vpc.default[0].subnets[local.ha_subnet_map[local.cloud]].cidr
        :
        aviatrix_vpc.default[0].public_subnets[local.ha_subnet_map[local.cloud]].cidr
      )
    )
  )

  ha_subnet_map = {
    azure = 0,
    aws   = 1,
    gcp   = length(var.ha_region) > 0 ? 1 : 0
    oci   = 0,
    ali   = 1,
  }

  region = local.cloud == "gcp" ? "${var.region}-${local.az1}" : var.region

  zone = local.cloud == "azure" ? local.az1 : null

  ha_zone = lookup(local.ha_zone_map, local.cloud, null)
  ha_zone_map = {
    azure = local.az2,
    gcp = (local.cloud == "gcp" ?
      (length(var.ha_region) > 0 ?
        "${var.ha_region}-${local.az2}"
        :
        "${var.region}-${local.az2}"
      )
      :
      null
    )
  }

  insane_mode_az = var.insane_mode ? lookup(local.insane_mode_az_map, local.cloud, null) : null
  insane_mode_az_map = {
    aws = local.cloud == "aws" ? "${var.region}${local.az1}" : null,
  }

  ha_insane_mode_az = var.insane_mode ? lookup(local.ha_insane_mode_az_map, local.cloud, null) : null
  ha_insane_mode_az_map = {
    aws = local.cloud == "aws" ? "${var.region}${local.az2}" : null,
  }

  is_china = can(regex("^cn-|^china ", lower(var.region))) && contains(["aws", "azure"], local.cloud)
  is_gov   = can(regex("^us-gov|^usgov |^usdod ", lower(var.region))) && contains(["aws", "azure"], local.cloud)

  cloud_type = local.is_china ? lookup(local.cloud_type_map_china, local.cloud, null) : (local.is_gov ? lookup(local.cloud_type_map_gov, local.cloud, null) : lookup(local.cloud_type_map, local.cloud, null))
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
    azure = 32,
    aws   = 256,
  }

  instance_size = length(var.instance_size) > 0 ? var.instance_size : lookup(local.instance_size_map, local.cloud, null)
  instance_size_map = {
    azure = "Standard_B1ms",
    aws   = "t3.medium",
    gcp   = "n1-standard-1",
    oci   = "VM.Standard2.2",
    ali   = "ecs.g5ne.large",
  }

  subnet_pairs = var.subnet_pairs != null ? var.subnet_pairs : lookup(local.subnet_pairs_map, local.cloud, null)
  subnet_pairs_map = {
    azure = 2,
    aws   = 2,
  }

  subnet_size = var.subnet_size != null ? var.subnet_size : lookup(local.subnet_size_map, local.cloud, null)
  subnet_size_map = {
    azure = 28,
    aws   = 28,
  }

  #Determine OCI Availability domains
  default_availability_domain    = var.use_existing_vpc ? null : (local.cloud == "oci" ? aviatrix_vpc.default[0].availability_domains[0] : null)
  default_fault_domain           = var.use_existing_vpc ? null : (local.cloud == "oci" ? aviatrix_vpc.default[0].fault_domains[0] : null)
  default_ha_availability_domain = var.use_existing_vpc ? null : (var.ha_gw && local.cloud == "oci" ? (try(aviatrix_vpc.default[0].availability_domains[1], aviatrix_vpc.default[0].availability_domains[0])) : null)
  default_ha_fault_domain        = var.use_existing_vpc ? null : (var.ha_gw && local.cloud == "oci" ? aviatrix_vpc.default[0].fault_domains[1] : null)

  availability_domain    = var.availability_domain != null ? var.availability_domain : local.default_availability_domain
  ha_availability_domain = var.ha_availability_domain != null ? var.ha_availability_domain : local.default_ha_availability_domain
  fault_domain           = var.fault_domain != null ? var.fault_domain : local.default_fault_domain
  ha_fault_domain        = var.ha_fault_domain != null ? var.ha_fault_domain : local.default_ha_fault_domain
}
