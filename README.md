# terraform-aviatrix-mc-spoke

### Description
Deploys a VPC/VNET/VCN and Aviatrix Spoke gateways. Also possible to use an existing VPC/VNET/VCN.

### Diagram
\<Provide a diagram of the high level constructs thet will be created by this module>
<img src="<IMG URL>"  height="250">

### Compatibility
Module version | Terraform version | Controller version | Terraform provider version
:--- | :--- | :--- | :---
v1.0.0 | 0.13-1.0.1 | >= 6.4 | >= 0.2.19

### Usage Example
```
module "spoke_aws_1" {
  source  = "terraform-aviatrix-modules/aws-spoke/aviatrix"
  version = "4.0.3"

  cloud           = "AWS"
  name            = "App1"
  cidr            = "10.1.0.0/20"
  region          = "eu-west-1"
  account         = "AWS"
  transit_gw      = "avx-eu-west-1-transit"
  security_domain = "blue"
}
```

### Variables
The following variables are required:

key | value
:--- | :---
cloud | Cloud where this is deployed. Valid values: "AWS", "Azure", "ALI", "OCI", "GCP"
name | Name for this spoke VPC and it's gateways
region | AWS region to deploy this VPC in
cidr | What ip CIDR to use for this VPC (Not required when use_existing_vpc is true)
account | The account name as known by the Aviatrix controller
transit_gw | The name of the transit gateway we want to attach this spoke to. Not required when attached is set to false.

The following variables are optional:

key | default | value 
:---|:---|:---
instance_size | t3.medium/b2ms | The size of the Aviatrix spoke gateways
ha_gw | true | Set to false if you only want to deploy a single Aviatrix spoke gateway
insane_mode | false | Set to true to enable insane mode encryption
az1 | "a" | concatenates with region to form az names. e.g. eu-central-1a. Used for insane mode only.
az2 | "b" | concatenates with region to form az names. e.g. eu-central-1b. Used for insane mode only.
active_mesh | true | Set to false to disable active mesh.
prefix | true | Boolean to enable prefix name with avx-
suffix | true | Boolean to enable suffix name with -spoke
attached | true | Set to false if you don't want to attach spoke to transit_gw.
attached_gw_egress | true | Set to false if you don't want to attach spoke to transit_gw_egress.
security_domain | | Provide security domain name to which spoke needs to be deployed. Transit gateway must be attached and have segmentation enabled.
single_az_ha | true | Set to false if Controller managed Gateway HA is desired
single_ip_snat | false | Specify whether to enable Source NAT feature in single_ip mode on the gateway or not. Please disable AWS NAT instance before enabling this feature. Currently only supports AWS(1) and AZURE(8)
customized_spoke_vpc_routes | | A list of comma separated CIDRs to be customized for the spoke VPC routes. When configured, it will replace all learned routes in VPC routing tables, including RFC1918 and non-RFC1918 CIDRs. Example: 10.0.0.0/116,10.2.0.0/16
filtered_spoke_vpc_routes | | A list of comma separated CIDRs to be filtered from the spoke VPC route table. When configured, filtering CIDR(s) or it’s subnet will be deleted from VPC routing tables as well as from spoke gateway’s routing table. Example: 10.2.0.0/116,10.3.0.0/16
included_advertised_spoke_routes | | A list of comma separated CIDRs to be advertised to on-prem as Included CIDR List. When configured, it will replace all advertised routes from this VPC. Example: 10.4.0.0/116,10.5.0.0/16
subnet_pairs | 2 | Number of Public/Private subnet pairs created in the VPC.
subnet_size | 28 | Size of the Public/Private subnets in the VPC.
enable_encrypt_volume | false | Set to true to enable EBS volume encryption for Gateway.
customer_managed_keys | null | Customer managed key ID for EBS Volume encryption.
private_vpc_default_route | false | Program default route in VPC private route table.
skip_public_route_table_update | false | Skip programming VPC public route table.
auto_advertise_s2c_cidrs | false | Auto Advertise Spoke Site2Cloud CIDRs.
tunnel_detection_time | null | The IPsec tunnel down detection time for the Spoke Gateway in seconds. Must be a number in the range [20-600]. Default is 60.
tags | null | Map of tags to assign to the gateway.
use_existing_vpc | false | Set to true to use an existing VPC in stead of having this module create one.
vpc_id | | VPC ID, for using an existing VPC.
gw_subnet | | Subnet CIDR, for using an existing VPC. Required when use_existing_vpc is enabled. Make sure this is a public subnet.
hagw_subnet | | Subnet CIDR, for using an existing VPC. Required when use_existing_vpc is enabled and ha_gw is true. Make sure this is a public subnet.
china | false | Set to true when deploying this module in AWS China
transit_gw_egress | | Add secondary transit to attach spoke to (e.g. for dual transit firenet). When segmentation is used, transit_gw MUST be used for east/west transit.
transit_gw_route_tables | [] | A list of route tables to propagate routes to for transit_gw attachment.
transit_gw_egress_route_tables | [] | A list of route tables to propagate routes to for transit_gw_egress attachment.
inspection | false | Set to true to enable east/west Firenet inspection. Only valid when transit_gw is East/West transit Firenet
gov | false | Set to true when deploying this module in AWS GOV

### Outputs
This module will return the following outputs:

key | description
:---|:---
\<keyname> | \<description of object that will be returned in this output>
