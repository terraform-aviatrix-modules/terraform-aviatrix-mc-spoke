# terraform-aviatrix-mc-transit release notes

## v1.1.3

### Improve dependency behavior
aviatrix_spoke_transit_attachment was changed to use spoke ID in stead of name, allowing for better dependency handling. Updating spoke where it will be replaced, will now cause the spoke-transit-attachment resource to also be destroyed.

### Improved Azure GOV and DoD region detection
Previously regex mismatched the regions, resulting in the wrong cloud type.

### Improved handling of small subnets
Previously, smaller than /26 was not supported for gateway subnets in order to maintain support for insane mode. Now it can be set to smaller values, if insane mode is disabled.

## v1.1.2

### Add compatibility for controller version 6.6.5545 and provider version 2.21.2.
