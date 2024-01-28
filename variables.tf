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
    condition     = length(var.name) <= 30
    error_message = "Name is too long. Max length is 30 characters."
  }

  validation {
    condition     = can(regex("^[a-zA-Z0-9-_]*$", var.name))
    error_message = "Only a-z, A-Z, 0-9 and hyphens and underscores are allowed."
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

  validation {
    condition     = can(regex("^[a-zA-Z0-9-_ ()]*$", var.region))
    error_message = "Only a-z, A-Z, 0-9, spaces, hyphens, parentheses and underscores are allowed."
  }
}

variable "ha_region" {
  description = "Secondary GCP region where subnet and HA Aviatrix Spoke Gateway will be created"
  type        = string
  default     = ""
  nullable    = false

  validation {
    condition     = can(regex("^[a-zA-Z0-9-_]*$", var.ha_region))
    error_message = "Only a-z, A-Z, 0-9 and hyphens and underscores are allowed."
  }
}

variable "cidr" {
  description = "The CIDR range to be used for the VPC"
  type        = string
  default     = ""
  nullable    = false

  validation {
    condition     = var.cidr == "" || can(cidrnetmask(var.cidr))
    error_message = "This does not like a valid CIDR."
  }
}

variable "ha_cidr" {
  description = "CIDR of the HA GCP subnet"
  type        = string
  default     = ""
  nullable    = false

  validation {
    condition     = var.ha_cidr == "" || can(cidrnetmask(var.ha_cidr))
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

variable "tunnel_count" {
  description = "The amount of tunnels for the spoke attachment"
  type        = number
  default     = null
}

variable "egress_tunnel_count" {
  description = "The amount of tunnels for the egress spoke attachment"
  type        = number
  default     = null
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

  validation {
    condition     = can(regex("^[a-zA-Z0-9-_]*$", var.network_domain))
    error_message = "Only a-z, A-Z, 0-9 and hyphens and underscores are allowed."
  }
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

  validation {
    condition     = var.customized_spoke_vpc_routes == "" || alltrue([for v in split(",", var.customized_spoke_vpc_routes) : can(cidrnetmask(trimspace(v)))])
    error_message = "All values in the string must be valid CIDR's and separated with comma's."
  }
}

variable "filtered_spoke_vpc_routes" {
  description = "A list of comma separated CIDRs to be filtered from the spoke VPC route table. When configured, filtering CIDR(s) or it’s subnet will be deleted from VPC routing tables as well as from spoke gateway’s routing table. It applies to this spoke gateway only. Example: 10.2.0.0/116,10.3.0.0/16"
  type        = string
  default     = ""
  nullable    = false

  validation {
    condition     = var.filtered_spoke_vpc_routes == "" || alltrue([for v in split(",", var.filtered_spoke_vpc_routes) : can(cidrnetmask(trimspace(v)))])
    error_message = "All values in the string must be valid CIDR's and separated with comma's."
  }
}

variable "included_advertised_spoke_routes" {
  description = "A list of comma separated CIDRs to be advertised to on-prem as Included CIDR List. When configured, it will replace all advertised routes from this VPC. Example: 10.4.0.0/116,10.5.0.0/16"
  type        = string
  default     = ""
  nullable    = false

  validation {
    condition     = var.included_advertised_spoke_routes == "" || alltrue([for v in split(",", var.included_advertised_spoke_routes) : can(cidrnetmask(trimspace(v)))])
    error_message = "All values in the string must be valid CIDR's and separated with comma's."
  }
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
    condition     = var.gw_subnet == "" || can(cidrnetmask(var.gw_subnet))
    error_message = "This does not like a valid CIDR."
  }
}

variable "hagw_subnet" {
  description = "Subnet CIDR, for using an existing VPC. Required when use_existing_vpc is true and ha_gw is true"
  type        = string
  default     = ""
  nullable    = false

  validation {
    condition     = var.hagw_subnet == "" || can(cidrnetmask(var.hagw_subnet))
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

  validation {
    condition     = var.spoke_bgp_manual_advertise_cidrs != null ? alltrue([for v in var.spoke_bgp_manual_advertise_cidrs : can(cidrnetmask(v))]) : true
    error_message = "All values in this list must be valid CIDR's."
  }
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

  validation {
    condition     = var.approved_learned_cidrs != null ? alltrue([for v in var.approved_learned_cidrs : can(cidrnetmask(v))]) : true
    error_message = "All values in this list must be valid CIDR's."
  }
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

variable "enable_monitor_gateway_subnets" {
  description = "Enables Monitor Gateway Subnet feature in AWS"
  type        = bool
  default     = false
}

variable "group_mode" {
  description = "Toggle to true if you are looking to use the new horizontal spoke gateway scaling."
  type        = bool
  default     = false
}

variable "spoke_gw_amount" {
  description = "The amount of spoke gateways to be created. group_mode needs to be true."
  type        = number
  default     = 2
}

variable "manage_ha_gateway" {
  description = "Determines if the aviatrix_spoke_gateway resource manages the HA gateway."
  type        = bool
  default     = true
}

variable "additional_group_mode_subnets" {
  description = "A list of subnets for when deploying more than 2 spoke gateways (group_mode). Should contain subnets for gateways 3-n. Mandatory when insane mode is used and deploying more than 2 gateways. Optional when existing_vpc is used."
  type        = list(string)
  default     = []

  validation {
    condition     = var.additional_group_mode_subnets == [] || alltrue([for v in var.additional_group_mode_subnets : can(cidrnetmask(v))])
    error_message = "All values in this list must be valid CIDR's."
  }
}

variable "additional_group_mode_azs" {
  description = "A list of AZ's for when deploying more than 2 spoke gateways (group_mode). Should contain AZ's for gateways 3-n. If not set, az1 and az2 will be used for subnet creation."
  type        = list(string)
  default     = []
}

variable "allocate_new_eip" {
  description = "When value is false, reuse an idle address in Elastic IP pool for this gateway. Otherwise, allocate a new Elastic IP and use it for this gateway."
  type        = bool
  default     = null
}

variable "eip" {
  description = "Required when allocate_new_eip is false. It uses the specified EIP for this gateway."
  type        = string
  default     = null

  validation {
    condition     = var.eip != null ? can(cidrnetmask(format("%s/32", var.eip))) : true
    error_message = "The input string must be a valid IPv4 address."
  }
}

variable "ha_eip" {
  description = "Required when allocate_new_eip is false. It uses the specified EIP for this gateway."
  type        = string
  default     = null

  validation {
    condition     = var.ha_eip != null ? can(cidrnetmask(format("%s/32", var.ha_eip))) : true
    error_message = "The input string must be a valid IPv4 address."
  }
}

variable "azure_eip_name_resource_group" {
  description = "Name of public IP Address resource and its resource group in Azure to be assigned to the Spoke Gateway instance."
  type        = string
  default     = null
}

variable "ha_azure_eip_name_resource_group" {
  description = "Name of public IP Address resource and its resource group in Azure to be assigned to the Spoke Gateway instance."
  type        = string
  default     = null
}

variable "additional_group_mode_eips" {
  description = "A list of EIP's for when deploying more than 2 spoke gateways (group_mode). Should contain EIP's for gateways 3-n. Required when allocate_new_eip is set to false."
  type        = list(string)
  default     = []

  validation {
    condition     = var.additional_group_mode_eips == [] || alltrue([for v in var.additional_group_mode_eips : can(cidrnetmask(format("%s/32", v)))])
    error_message = "All values in this list must be valid CIDR's."
  }
}

variable "additional_group_mode_azure_eip_name_resource_groups" {
  description = "A list of Names of public IP Address resource and its resource group in Azure to be assigned to the Spoke Gateway instances. For when deploying more than 2 spoke gateways (group_mode). Should contain entries for gateways 3-n. Required when allocate_new_eip is set to false."
  type        = list(string)
  default     = []
}

variable "disable_route_propagation" {
  description = "Disables route propagation on BGP Spoke to attached Transit Gateway."
  type        = bool
  default     = null
}

variable "enable_global_vpc" {
  description = "Enables global VPC mode in GCP."
  type        = bool
  default     = null
}

variable "enable_gro_gso" {
  description = "Enable GRO/GSO for this spoke gateway."
  type        = bool
  default     = null
}

variable "additional_gcp_subnets" {
  description = "Additional subnets to be created in GCP. Expects a map of maps with cidr and region."
  type        = map(map(any))
  default     = {}
}

variable "enable_bgp_over_lan" {
  description = "Pre-allocate a network interface(eth4) for \"BGP over LAN\" functionality. Must be enabled to create a BGP over LAN."
  type        = bool
  default     = null
}

variable "bgp_lan_interfaces_count" {
  description = "Number of interfaces that will be created for BGP over LAN enabled Azure spoke."
  type        = number
  default     = null
}

variable "enable_vpc_dns_server" {
  description = "Enable VPC DNS Server for Gateway."
  type        = bool
  default     = null
}

variable "enable_active_standby_preemptive" {
  description = "Enables Preemptive Mode for Active-Standby."
  type        = bool
  default     = null
}
