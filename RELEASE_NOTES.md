# terraform-aviatrix-mc-spoke release notes

## 8.0.0
### Version Alignment
Starting with this release, this Terraform module will align its version with the Aviatrix Controller version. This means the module version has jumped from v1.7.1 to v8.0.0 to align with the Controller’s latest major version. This change makes it easier to determine which module version is compatible with which Controller version.

### Relaxed version constraints
Starting with this release, this Terraform module will move from a pessimistic constraint operator (`~>`) to a more relaxed provider version constraint (`>=`). As a result of this, module versions 8.0.0 and above can be used with newer (future) version of the Aviatrix Terraform provider, with the constraint that the newer provider version cannot have behavioral changes.
The reason for this change is to allow users to upgrade their controller and Terraform provider versions, without requiring to upgrade all their Terraform module versions, unless any of the following exceptions are true:
- User requires access to new feature flags, that are only exposed in newer Terraform module versions.
- The new Terraform provider version does not introduce behavior changes that are incompatible with the module version.

### Future releases
A new major module version will be released _only_ when:
- A new major Aviatrix Terraform provider has been released AND introduces new features or breaking changes.

A new minor module version will be released when:
- Bug fixes or missed features that were already available in the same release train as the Aviatrix Terraform provider.

## 1.7.1

### Fix issue where gateways were rebuild on every apply in GCP.

## 1.7.0

### Add support for Controller version 7.2 / Terraform provider version 3.2.x

## 1.6.10

### Add support for enable_jumbo_frames

## 1.6.9

### Add support for learned_cidrs_approval_mode

## 1.6.8

### Add tunnel count for attachments.
### Fix input for ha_azure_eip_name_resource_group

## 1.6.7

### Adjusted Azure example to contain GUID
Thank you @Sevenlive for the PR.

### Added support for enable_active_standby_preemptive

## 1.6.6

### Fixed too agressive region validation in Alibaba

### Included additional examples

## 1.6.5

### Improve group mode behavior in Azure and GCP

### Refactored logic in locals and input validation

## 1.6.4

### Add support for setting `enable_vpc_dns_server` attribute.

## 1.6.3

### Add support for BGP attributes
Added support for `enable_bgp_over_lan` and `bgp_lan_interfaces_count` attributes.

## 1.6.2

### Add support for adding multiple subnets to a VPC in GCP
This feature allows you to create a VPC with additional subnets. The primary use case is to allow you to build global spoke VPC's with subnets in multiple regions, without having to resort to native GCP resources.

### GCP Subnet naming convention change
Previously, subnets in GCP were always named the same as the VPC. Since global VPC allows you to deploy in multiple regions, it seems more apptly to follow the gateway name for naming the subnet. Subnet names are now set using the optional `gw_name` variable. If you're not using this variable, they will remain using the VPC naming.

## 1.6.1

### Fix issue on non-aws clouds on destroy
│ Error: Invalid function argument │ │ on .terraform/modules/spoke_1/locals.tf line 82, in locals: │ 82: aws = var.use_existing_vpc ? [] : slice(aviatrix_vpc.default[0].public_subnets.*.cidr, 2, length(aviatrix_vpc.default[0].public_subnets)), #Get the rest of the public subnets, minus the first 2.

## 1.6.0

### Compatibility with controller version 7.1 and Terraform provider version 3.1.x

### Add support for GCP global VPC

### Implemented support for GRO/GSO on this gateway.
Enabled by default and enhances gateway performance. This setting can be used to turn it off.

## 1.5.2

### Add support for disable_route_propagation

## 1.5.1

### Add support for custom EIP's
New supported arguments for this feature:
* allocate_new_eip
* eip
* ha_eip
* azure_eip_name_resource_group
* ha_azure_eip_name_resource_group
* additional_group_mode_eips
* additional_group_mode_azure_eip_name_resource_groups

### Add outputs for all ha gateways

### Broken out locals to separate file
For beter readability, the locals are no longer part of variables.tf and can now be found in locals.tf.

### Implemented support for group mode
This feature allows for more than 2 spoke gateways to be deployed in a spoke. For details on migrating from traditional to group mode, check this [doc](https://github.com/terraform-aviatrix-modules/terraform-aviatrix-mc-spoke/blob/master/docs/GROUP_MODE_MIGRATION.md).

New supported arguments for this feature:
* additional_group_mode_subnets
* additional_group_mode_azs
* group_mode
* spoke_gw_amount
* manage_ha_gateway

## 1.5.0

### Add support for Controller version 7.0 and Terraform provider 3.0.0.
This release is purely providing compatibility with these versions. New features that are part of the 7.0.0/3.0.0 release will be part of subsequent releases.

## 1.4.2

### Switch from gw_name to id attribute for resources referring to the spoke gateway. This provides better lifecycle handling.

### Add support for gateway subnet monitoring in AWS

## 1.4.1

### Controller version 6.9 / Terraform provider version 2.24.x compatibility

## 1.4.0

### ~~Controller version 6.9 / Terraform provider version 2.24.x compatibility~~
This version was pulled because of a bug

## v1.3.2

### [Issue#8](https://github.com/terraform-aviatrix-modules/terraform-aviatrix-mc-spoke/issues/8) - Fix network segmentation on GW recreation 
In scenario's where the spoke gateway needs to be recreated (e.g. moving from non-HPE to HPE), the new gateway would not be reattached to the network domain.
Switching from gw_name to id as reference resolves this.

### [Issue#10](https://github.com/terraform-aviatrix-modules/terraform-aviatrix-mc-spoke/issues/10) - Improve lifecycle handing 
In certain scenario's spoke attachment and network domain association need to be recreated. This is handled with the replace_triggered_by argument added in Terraform 1.2.0.

## v1.3.1

### Fix an issue with enable_max_performance argument

### Change private mode behavior (better logic and automation)

## v1.3.0

### Add support for 6.8 and provider version 2.23.0.

### Add support for private mode
These arguments were added to support this:

- private_mode_subnets
- private_mode_lb_vpc_id
- private_mode_subnet_zone
- ha_private_mode_subnet_zone

### Add support for new arguments on transit attachment
- enable_max_performance
- spoke_prepend_as_path
- transit_prepend_as_path

## v1.2.4

### Add support for explicit spoke gateway name configuration
By default this module will use the name argument for both VPC/VNET creation as well as spoke gateway. You can now override the gateway name with the gw_name argument.

### Input variables non-nullable
Most input variables that have a default value, have been set to be non-nullable as of this release. This allows parent or root modules calling this module to set arguments to null without changing the internal behavior of the module. This should cause no impact to existing usage.

## v1.2.3

### Add support for provider 2.22.1.

### Add support for new argument enable_preserve_as_path

## v1.2.2

### Automatically disable AZ support for Azure Gov and DoD regions
As availability zones are not supported in the Aviatrix controller for Gov and DoD regions, the module automatically selects az_support = false, for these regions.

### Fix issue where deployment in OCI was failing when insane mode was enabled
In previous versions, the wrong subnet was selected for deploying the spoke gateway(s).

### Automatically truncate VPC/VNET/VCN names at 30 characters
Controller does not allow for names longer than 30 characters for VPC's, VNET'sand VCN's. As of this version, any names longer than that are automatically truncated.

### Set output aviatrix_spoke_gateway to sensitive for terragrunt compatibility.

## v1.2.1

### Make OCI availability and fault domains user configurable.
New variables available for configuration:
```
availability_domain
ha_availability_domain
fault_domain
ha_fault_domain
```

### Fix OCI availability domains selection for single AD regions.
Previously, the module assumed multiple AD's available in every region. As per this release, it can handle single AD regions as well.

## v1.2.0

### Add support for controller version 6.7.1186 and provider version 2.22.0.

### Updated security domain resource
As per this note, in 6.7 and provider version 2.22.0, the aviatrix_segmentation_security_domain_association resource has been renamed to aviatrix_segmentation_network_domain_association.
Follow the guidance in the note to migrate to this module version. Failure to do so, may result in downtime, as upgrading to this module version will force the existing aviatrix_segmentation_security_domain_association to be removed while the aviatrix_segmentation_network_domain_association may not yet be in place.

### Add support for rx_queue_size
This option allows you to increase the receive buffer size. This may be required in scenarios where traffic is particularly bursty.

## v1.1.3

### Improve dependency behavior
aviatrix_spoke_transit_attachment was changed to use spoke ID in stead of name, allowing for better dependency handling. Updating spoke where it will be replaced, will now cause the spoke-transit-attachment resource to also be destroyed.

### Improved Azure GOV and DoD region detection
Previously regex mismatched the regions, resulting in the wrong cloud type.

### Improved handling of small subnets
Previously, smaller than /26 was not supported for gateway subnets in order to maintain support for insane mode. Now it can be set to smaller values, if insane mode is disabled.

## v1.1.2

### Add compatibility for controller version 6.6.5545 and provider version 2.21.2.
