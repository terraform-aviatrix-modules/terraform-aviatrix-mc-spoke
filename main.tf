# Aviatrix Spoke VPC
resource "aviatrix_vpc" "default" {
  count                = var.use_existing_vpc ? 0 : 1
  cloud_type           = local.cloud_type
  region               = local.cloud == "gcp" ? null : var.region
  cidr                 = local.cloud == "gcp" ? null : var.cidr
  account_name         = var.account
  name                 = var.name
  aviatrix_transit_vpc = false
  aviatrix_firenet_vpc = false
  num_of_subnet_pairs  = local.subnet_pairs
  subnet_size          = local.subnet_size
  resource_group       = var.resource_group
  private_mode_subnets = var.private_mode_subnets

  dynamic "subnets" {
    for_each = local.cloud == "gcp" ? ["dummy"] : [] #Trick to make block conditional. Count not available on dynamic blocks.
    content {
      name   = local.gw_name
      cidr   = var.cidr
      region = var.region
    }
  }

  dynamic "subnets" {
    for_each = local.cloud == "gcp" && length(var.ha_region) > 0 ? ["dummy"] : [] #Trick to make block conditional. Count not available on dynamic blocks.
    content {
      name   = "${local.gw_name}-ha"
      cidr   = var.ha_cidr
      region = var.ha_region
    }
  }

  dynamic "subnets" {
    for_each = var.additional_gcp_subnets
    content {
      name   = subnets.key
      cidr   = subnets.value.cidr
      region = subnets.value.region
    }
  }
}

#Spoke GW
resource "aviatrix_spoke_gateway" "default" {
  cloud_type                            = local.cloud_type
  vpc_reg                               = local.region
  gw_name                               = coalesce(local.gw_name, var.name)
  gw_size                               = local.instance_size
  vpc_id                                = var.use_existing_vpc ? var.vpc_id : aviatrix_vpc.default[0].vpc_id
  account_name                          = var.account
  subnet                                = local.subnet
  zone                                  = local.zone
  insane_mode                           = var.insane_mode
  insane_mode_az                        = local.insane_mode_az
  single_az_ha                          = var.single_az_ha
  single_ip_snat                        = var.single_ip_snat
  customized_spoke_vpc_routes           = var.customized_spoke_vpc_routes
  filtered_spoke_vpc_routes             = var.filtered_spoke_vpc_routes
  included_advertised_spoke_routes      = var.included_advertised_spoke_routes
  enable_encrypt_volume                 = var.enable_encrypt_volume
  customer_managed_keys                 = var.customer_managed_keys
  enable_private_vpc_default_route      = var.private_vpc_default_route
  enable_skip_public_route_table_update = var.skip_public_route_table_update
  enable_auto_advertise_s2c_cidrs       = var.auto_advertise_s2c_cidrs
  tunnel_detection_time                 = var.tunnel_detection_time
  tags                                  = var.tags
  availability_domain                   = local.availability_domain
  fault_domain                          = local.fault_domain
  enable_active_standby                 = var.enable_active_standby
  prepend_as_path                       = var.prepend_as_path
  enable_learned_cidrs_approval         = var.enable_learned_cidrs_approval
  learned_cidrs_approval_mode           = var.learned_cidrs_approval_mode
  approved_learned_cidrs                = var.approved_learned_cidrs
  local_as_number                       = var.local_as_number
  rx_queue_size                         = var.rx_queue_size
  enable_preserve_as_path               = var.enable_preserve_as_path
  enable_monitor_gateway_subnets        = var.enable_monitor_gateway_subnets
  disable_route_propagation             = var.disable_route_propagation
  enable_global_vpc                     = var.enable_global_vpc
  enable_gro_gso                        = var.enable_gro_gso
  enable_vpc_dns_server                 = var.enable_vpc_dns_server

  #BGP Settings
  enable_bgp                       = var.enable_bgp
  spoke_bgp_manual_advertise_cidrs = var.spoke_bgp_manual_advertise_cidrs
  bgp_ecmp                         = var.bgp_ecmp
  bgp_polling_time                 = var.bgp_polling_time
  bgp_hold_time                    = var.bgp_hold_time
  enable_bgp_over_lan              = var.enable_bgp_over_lan
  bgp_lan_interfaces_count         = var.bgp_lan_interfaces_count

  #HA Settings - only apply when ha_gw is enabled and group mode is disabled (legacy behavior)
  ha_subnet              = local.ha_gw ? local.ha_subnet : null
  ha_gw_size             = local.ha_gw ? local.instance_size : null
  ha_zone                = local.ha_gw ? local.ha_zone : null
  ha_availability_domain = local.ha_gw ? local.ha_availability_domain : null
  ha_fault_domain        = local.ha_gw ? local.ha_fault_domain : null
  ha_insane_mode_az      = local.ha_gw ? local.ha_insane_mode_az : null
  manage_ha_gateway      = local.manage_ha_gateway

  #Private mode settings
  private_mode_lb_vpc_id      = var.private_mode_lb_vpc_id
  private_mode_subnet_zone    = var.private_mode_subnets && local.cloud == "aws" ? format("%s%s", var.region, local.az1) : null
  ha_private_mode_subnet_zone = var.private_mode_subnets && local.cloud == "aws" && local.ha_gw ? format("%s%s", var.region, local.az2) : null

  #Custom EIP settings
  allocate_new_eip                 = var.allocate_new_eip
  eip                              = var.eip
  ha_eip                           = local.ha_gw ? var.ha_eip : null
  azure_eip_name_resource_group    = var.azure_eip_name_resource_group
  ha_azure_eip_name_resource_group = local.ha_gw ? var.azure_eip_name_resource_group : null
}

resource "aviatrix_spoke_ha_gateway" "hagw" {
  count = var.group_mode && var.spoke_gw_amount > 1 ? 1 : 0

  primary_gw_name               = aviatrix_spoke_gateway.default.id
  gw_name                       = format("%s-hagw", local.gw_name)
  gw_size                       = local.instance_size
  subnet                        = local.ha_subnet
  zone                          = local.ha_zone
  availability_domain           = local.ha_availability_domain
  fault_domain                  = local.ha_fault_domain
  insane_mode                   = var.insane_mode
  insane_mode_az                = local.ha_insane_mode_az
  eip                           = var.ha_eip
  azure_eip_name_resource_group = var.ha_azure_eip_name_resource_group
}

#Additional gateways will be balanced across subnets/az's/zones etc. Only in case of insane mode a list of additional subnets is expected.
resource "aviatrix_spoke_ha_gateway" "additional" {
  count = var.group_mode ? max(var.spoke_gw_amount - 2, 0) : 0

  primary_gw_name               = aviatrix_spoke_gateway.default.id
  gw_name                       = format("%s-%s", local.gw_name, count.index + 3)
  gw_size                       = local.instance_size
  subnet                        = var.insane_mode || var.use_existing_vpc ? var.additional_group_mode_subnets[count.index] : local.group_mode_subnet_list[((count.index + 2) % length(local.group_mode_subnet_list))]
  zone                          = local.cloud != "aws" ? local.group_mode_az_list[(count.index + 2) % length(local.group_mode_az_list)] : null
  availability_domain           = [local.availability_domain, local.ha_availability_domain][count.index % 2]
  fault_domain                  = [local.fault_domain, local.ha_fault_domain][count.index % 2]
  insane_mode                   = var.insane_mode
  insane_mode_az                = local.cloud == "aws" ? local.group_mode_az_list[(count.index + 2) % length(local.group_mode_az_list)] : null
  eip                           = var.allocate_new_eip != null ? var.additional_group_mode_eips[count.index] : null
  azure_eip_name_resource_group = var.allocate_new_eip != null && local.cloud == "azure" ? var.additional_group_mode_azure_eip_name_resource_groups[count.index] : null

  depends_on = [
    aviatrix_spoke_ha_gateway.hagw
  ]
}

resource "aviatrix_spoke_transit_attachment" "default" {
  count                   = var.attached ? 1 : 0
  spoke_gw_name           = aviatrix_spoke_gateway.default.id
  transit_gw_name         = var.transit_gw
  route_tables            = var.transit_gw_route_tables
  enable_max_performance  = var.enable_max_performance
  spoke_prepend_as_path   = var.spoke_prepend_as_path
  transit_prepend_as_path = var.transit_prepend_as_path

  lifecycle {
    replace_triggered_by = [
      aviatrix_spoke_gateway.default.ha_subnet, #Attachment needs to be replaced as well, if HA Subnet changes (due to toggling HA on or off)
    ]
  }

  depends_on = [aviatrix_spoke_ha_gateway.additional]
}

resource "aviatrix_spoke_transit_attachment" "transit_gw_egress" {
  count                   = length(var.transit_gw_egress) > 0 && var.attached_gw_egress ? 1 : 0
  spoke_gw_name           = aviatrix_spoke_gateway.default.id
  transit_gw_name         = var.transit_gw_egress
  route_tables            = var.transit_gw_egress_route_tables
  enable_max_performance  = var.enable_max_performance
  spoke_prepend_as_path   = var.spoke_prepend_as_path
  transit_prepend_as_path = var.transit_prepend_as_path

  lifecycle {
    replace_triggered_by = [
      aviatrix_spoke_gateway.default.ha_subnet, #Attachment needs to be replaced as well, if HA Subnet changes (due to toggling HA on or off)
    ]
  }

  depends_on = [aviatrix_spoke_ha_gateway.additional]
}

resource "aviatrix_segmentation_network_domain_association" "default" {
  count                = length(var.network_domain) > 0 && var.attached ? 1 : 0 #Only create resource when attached and network_domain is set.
  transit_gateway_name = var.transit_gw
  network_domain_name  = var.network_domain
  attachment_name      = aviatrix_spoke_gateway.default.id
  depends_on           = [aviatrix_spoke_transit_attachment.default] #Let's make sure this cannot create a race condition

  lifecycle {
    replace_triggered_by = [
      aviatrix_spoke_transit_attachment.default, #If transit attachment gets recreated, network domain needs to follow along
    ]
  }
}

resource "aviatrix_transit_firenet_policy" "default" {
  count                        = var.inspection && var.attached ? 1 : 0
  transit_firenet_gateway_name = var.transit_gw
  inspected_resource_name      = "SPOKE:${aviatrix_spoke_gateway.default.id}"
  depends_on                   = [aviatrix_spoke_transit_attachment.default] #Let's make sure this cannot create a race condition
}

resource "aviatrix_spoke_gateway_subnet_group" "subnet_groups" {
  for_each = var.subnet_groups

  name    = each.key
  gw_name = aviatrix_spoke_gateway.default.id
  subnets = each.value

  depends_on = [
    aviatrix_spoke_transit_attachment.default,
    aviatrix_spoke_transit_attachment.transit_gw_egress,
  ]
}
