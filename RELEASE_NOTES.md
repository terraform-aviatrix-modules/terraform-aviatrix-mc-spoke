# terraform-aviatrix-mc-spoke release notes

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
