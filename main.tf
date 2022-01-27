# Aviatrix Spoke VPC
resource "aviatrix_vpc" "default" {
  count                = var.use_existing_vpc ? 0 : 1
  cloud_type           = local.cloud_type
  region               = local.cloud == "gcp" ? null : var.region
  cidr                 = local.cloud == "gcp" ? null : var.cidr
  account_name         = var.account
  name                 = local.name
  aviatrix_transit_vpc = false
  aviatrix_firenet_vpc = false
  num_of_subnet_pairs  = local.subnet_pairs
  subnet_size          = local.subnet_size
  resource_group       = var.resource_group

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
  gw_name                               = local.name
  gw_size                               = local.instance_size
  vpc_id                                = var.use_existing_vpc ? var.vpc_id : (local.cloud == "oci" ? aviatrix_vpc.default[0].name : aviatrix_vpc.default[0].vpc_id)
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
  availability_domain                   = local.cloud == "oci" ? aviatrix_vpc.default[0].availability_domains[0] : null
  fault_domain                          = local.cloud == "oci" ? aviatrix_vpc.default[0].fault_domains[0] : null
  ha_availability_domain                = var.ha_gw ? (local.cloud == "oci" ? aviatrix_vpc.default[0].availability_domains[1] : null) : null
  ha_fault_domain                       = var.ha_gw ? (local.cloud == "oci" ? aviatrix_vpc.default[0].fault_domains[1] : null) : null
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
}

resource "aviatrix_spoke_transit_attachment" "default" {
  count           = var.attached ? 1 : 0
  spoke_gw_name   = aviatrix_spoke_gateway.default.gw_name
  transit_gw_name = var.transit_gw
  route_tables    = var.transit_gw_route_tables
}

resource "aviatrix_spoke_transit_attachment" "transit_gw_egress" {
  count           = length(var.transit_gw_egress) > 0 ? (var.attached_gw_egress ? 1 : 0) : 0
  spoke_gw_name   = aviatrix_spoke_gateway.default.gw_name
  transit_gw_name = var.transit_gw_egress
  route_tables    = var.transit_gw_egress_route_tables
}

resource "aviatrix_segmentation_security_domain_association" "default" {
  count                = var.attached ? (length(var.security_domain) > 0 ? 1 : 0) : 0 #Only create resource when attached and security_domain is set.
  transit_gateway_name = var.transit_gw
  security_domain_name = var.security_domain
  attachment_name      = aviatrix_spoke_gateway.default.gw_name
  depends_on           = [aviatrix_spoke_transit_attachment.default] #Let's make sure this cannot create a race condition
}

resource "aviatrix_transit_firenet_policy" "default" {
  count                        = var.inspection ? (var.attached ? 1 : 0) : 0
  transit_firenet_gateway_name = var.transit_gw
  inspected_resource_name      = "SPOKE:${aviatrix_spoke_gateway.default.gw_name}"
  depends_on                   = [aviatrix_spoke_transit_attachment.default] #Let's make sure this cannot create a race condition
}
