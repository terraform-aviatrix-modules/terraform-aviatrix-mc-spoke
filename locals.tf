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
  ha_gw                 = var.group_mode ? false : var.ha_gw
  manage_ha_gateway     = var.group_mode ? false : var.manage_ha_gateway

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

  #Group mode subnetting
  additional_group_mode_subnets = try(coalescelist(var.additional_group_mode_subnets, lookup(local.additional_group_mode_subnets_map, local.cloud, [])), [])
  additional_group_mode_subnets_map = {
    aws = var.use_existing_vpc ? [] : slice(aviatrix_vpc.default[0].public_subnets.*.cidr, 2, length(aviatrix_vpc.default[0].public_subnets)), #Get the rest of the public subnets, minus the first 2.
  }

  group_mode_subnet_list = concat(
    [local.subnet],
    [local.ha_subnet],
    local.additional_group_mode_subnets
  )

  group_mode_subnet_list_length = length(local.group_mode_subnet_list)

  #group mode AZ's
  group_mode_az_list = concat(
    [local.insane_mode_az],
    [local.ha_insane_mode_az],
    var.additional_group_mode_azs
  )

  group_mode_az_list_length = length(local.group_mode_az_list)

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
