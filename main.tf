# Aviatrix Spoke VPC
resource "aviatrix_vpc" "default" {
  count                = var.use_existing_vpc ? 0 : 1
  cloud_type           = local.cloud_type
  region               = local.cloud == "gcp" ? null : var.region
  cidr                 = local.cloud == "gcp" ? null : var.cidr
  account_name         = var.account
  name                 = substr(local.name, 0, 30)
  aviatrix_transit_vpc = false
  aviatrix_firenet_vpc = false
  num_of_subnet_pairs  = local.subnet_pairs
  subnet_size          = local.subnet_size
  resource_group       = var.resource_group
  private_mode_subnets = var.private_mode_subnets

  dynamic "subnets" {
    for_each = local.cloud == "gcp" ? ["dummy"] : [] #Trick to make block conditional. Count not available on dynamic blocks.
    content {
      name   = local.name
      cidr   = var.cidr
      region = var.region
    }
  }

  dynamic "subnets" {
    for_each = length(var.ha_region) > 0 ? ["dummy"] : [] #Trick to make block conditional. Count not available on dynamic blocks.
    content {
      name   = "${local.name}-ha"
      cidr   = var.ha_cidr
      region = var.ha_region
    }
  }
}

#Spoke GW
resource "aviatrix_spoke_gateway" "default" {
  cloud_type                            = local.cloud_type
  vpc_reg                               = local.region
  gw_name                               = local.gw_name
  gw_size                               = local.instance_size
  vpc_id                                = var.use_existing_vpc ? var.vpc_id : aviatrix_vpc.default[0].vpc_id
  account_name                          = var.account
  subnet                                = local.subnet
  zone                                  = local.zone
  ha_subnet                             = var.ha_gw ? local.ha_subnet : null
  ha_gw_size                            = var.ha_gw ? local.instance_size : null
  ha_zone                               = var.ha_gw ? local.ha_zone : null
  insane_mode                           = var.insane_mode
  insane_mode_az                        = local.insane_mode_az
  ha_insane_mode_az                     = var.ha_gw ? local.ha_insane_mode_az : null
  manage_transit_gateway_attachment     = false
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
  ha_availability_domain                = local.ha_availability_domain
  ha_fault_domain                       = local.ha_fault_domain
  enable_bgp                            = var.enable_bgp
  spoke_bgp_manual_advertise_cidrs      = var.spoke_bgp_manual_advertise_cidrs
  bgp_ecmp                              = var.bgp_ecmp
  enable_active_standby                 = var.enable_active_standby
  prepend_as_path                       = var.prepend_as_path
  bgp_polling_time                      = var.bgp_polling_time
  bgp_hold_time                         = var.bgp_hold_time
  enable_learned_cidrs_approval         = var.enable_learned_cidrs_approval
  learned_cidrs_approval_mode           = var.learned_cidrs_approval_mode
  approved_learned_cidrs                = var.approved_learned_cidrs
  local_as_number                       = var.local_as_number
  rx_queue_size                         = var.rx_queue_size
  enable_preserve_as_path               = var.enable_preserve_as_path

  #Private mode settings
  private_mode_lb_vpc_id      = var.private_mode_lb_vpc_id
  private_mode_subnet_zone    = var.private_mode_subnets && local.cloud == "aws" ? format("%s%s", var.region, local.az1) : null
  ha_private_mode_subnet_zone = var.private_mode_subnets && local.cloud == "aws" && var.ha_gw ? format("%s%s", var.region, local.az2) : null
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
  inspected_resource_name      = "SPOKE:${aviatrix_spoke_gateway.default.gw_name}"
  depends_on                   = [aviatrix_spoke_transit_attachment.default] #Let's make sure this cannot create a race condition
}

resource "aviatrix_spoke_gateway_subnet_group" "subnet_groups" {
  for_each = var.subnet_groups

  name    = each.key
  gw_name = aviatrix_spoke_gateway.default.gw_name
  subnets = each.value

  depends_on = [
    aviatrix_spoke_transit_attachment.default,
    aviatrix_spoke_transit_attachment.transit_gw_egress,
  ]
}
