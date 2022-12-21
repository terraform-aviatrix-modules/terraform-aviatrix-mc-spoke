# Migrating from legacy HA (1+1) to Group mode (1+N)
This feature was introduced in 7.0 and support horizontal scalability of gateways in the spoke. In stead of having a primary and an HA gateway, you can now have up to <x> gateways in a spoke VPC/VNET.

## Impact
As the current ha gateway needs to be removed before the new additional gateways can be deployed, there may be impact on traffic flows. Execute this change in a maintenance window.

## Procedure
Moving from legacy HA to group mode is very simple. Follow the steps below:
- Set `manage_ha_gateway = false` on the module and apply the changes. This will take away control of the hagw from the aviatrix_spoke_gateway.
- Add `group_mode = true` to your mc-spoke module configuration. A new instance of the `aviatrix_spoke_ha_gateway` with the same properties will be created. Do no apply your changes, as we want to import the existing hagw against this instance.
- Import the existing hagw against the new `aviatrix_spoke_ha_gateway` Terraform resource using this command: `terraform import module.<module_name>.aviatrix_spoke_ha_gateway.hagw[0] <name of the hagw>`
- Once done, you can remove the `manage_ha_gateway` statement from the module, as the module will automatically enforce it when `group_mode` is enabled.

## Expanding
Once you have migrated from a legacy to group based HA, you can expand the amount of spoke gateways using the `spoke_gateway_amount` argument. This defaults to 2, creating 1+1 gateways. By increasing this number to the desired total number of gateways in the spoke, it will add instances of the `aviatrix_spoke_ha_gateway` resource.

## Limitations
- For backward compatibility (in order to be able to import), the second gateway will always be appended with -hagw. Any additional gateways will simple get a number (3 and up) to identify it.
- Any additional gateways deployed will be distributed over the same AZ's/zones as the first 2 gateways. This module currently does not support a 3 or more AZ distribution.
- When using insane_mode, /26 subnets for the gateways 3-n need to be supplied as an additional list using the `group_mode_insane_mode_subnets` argument.
- Deploying additional gateways has to be done one by one. Increasing the `spoke_gateway_amount` by more than one will result in an error. Either increase one by one or apply multiple times.
