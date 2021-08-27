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
<br><br><br>
<table>
    <tr>
      <th style="transform: rotate(-90deg);white-space:nowrap;column-width: 10px;">AWS</th>
      <th style="transform: rotate(-90deg);white-space:nowrap;column-width: 10px;">Azure</th>
      <th style="transform: rotate(-90deg);white-space:nowrap;column-width: 10px;">GCP</th>
      <th style="transform: rotate(-90deg);white-space:nowrap;column-width: 10px;">OCI</th>
      <th style="transform: rotate(-90deg);white-space:nowrap;column-width: 10px;">Alibaba</th>      
    </tr>
    <tr>
      <td colspan="5" align="center"><b>Supported CSP's</b></td>    
      <th>Key</th>
      <th>Default</th>
      <th>Description</th>
    </tr>
    <tr><td></td><td></td><td></td><td></td><td></td>
      <td style="text-align:right">instance_size</td>
      <td>t3.medium/Standard_B1ms</td>
      <td>The size of the Aviatrix spoke gateways</td>
    </tr>
    <tr><td></td><td></td><td></td><td></td><td></td>
      <td>ha_gw</td>
      <td>true</td>
      <td>Set to false if you only want to deploy a single Aviatrix spoke gateway</td>
    </tr>  
    <tr><td></td><td></td><td></td><td></td><td class="alibaba unsupported"></td>
      <td>insane_mode</td>
      <td>false</td>
      <td>Set to true to enable insane mode encryption</td>
    </tr>      
    <tr><td></td><td></td><td></td><td class="oci unsupported"></td><td class="alibaba unsupported"></td>
      <td>az1</td>
      <td>"a"/b/az-1</td>
      <td>concatenates with region to form az names. e.g. eu-central-1a. Used for insane mode only.</td>
    </tr>  
    <tr><td></td><td></td><td></td><td class="oci unsupported"></td><td class="alibaba unsupported"></td>
      <td>az2</td>
      <td>"b"/c/az-2</td>
      <td>concatenates with region to form az names. e.g. eu-central-1b. Used for insane mode only.</td>
    </tr>  
    <tr><td></td><td></td><td></td><td></td><td></td>
      <td>active_mesh</td>
      <td>true</td>
      <td>Set to false to disable active mesh.</td>
    </tr>    
    <tr><td></td><td></td><td></td><td></td><td></td>
      <td>prefix</td>
      <td>true</td>
      <td>Boolean to enable prefix name with avx-</td>
    </tr>  
    <tr><td></td><td></td><td></td><td></td><td></td>
      <td>suffix</td>
      <td>true</td>
      <td>Boolean to enable suffix name with -spoke</td>
    </tr>
    <tr><td></td><td></td><td></td><td></td><td></td>
      <td>attached</td>
      <td>true</td>
      <td>Set to false if you don't want to attach spoke to transit_gw.</td>
    </tr>
    <tr><td></td><td></td><td></td><td></td><td></td>
      <td>attached_gw_egress</td>
      <td>true</td>
      <td>Set to false if you don't want to attach spoke to transit_gw_egress.</td>
    </tr>
    <tr><td></td><td></td><td></td><td></td><td></td>
      <td>security_domain</td>
      <td></td>
      <td>Provide security domain name to which spoke needs to be deployed. Transit gateway must be attached and have segmentation enabled.</td>
    </tr>
    <tr><td></td><td></td><td></td><td></td><td></td>
      <td>single_az_ha</td>
      <td>true</td>
      <td>Set to false if Controller managed Gateway HA is desired</td>
    </tr>
    <tr><td></td><td></td><td></td><td></td><td></td>
      <td>single_ip_snat</td>
      <td>false</td>
      <td>Specify whether to enable Source NAT feature in single_ip mode on the gateway or not. Please disable AWS NAT instance before enabling this feature. Currently only supports AWS(1) and AZURE(8)</td>
    </tr>
    <tr><td></td><td></td><td></td><td></td><td></td>
      <td>customized_spoke_vpc_routes</td>
      <td></td>
      <td>A list of comma separated CIDRs to be customized for the spoke VPC routes. When configured, it will replace all learned routes in VPC routing tables, including RFC1918 and non-RFC1918 CIDRs. Example: 10.0.0.0/116,10.2.0.0/16</td>
    </tr>  
    <tr><td></td><td></td><td></td><td></td><td></td>
      <td>filtered_spoke_vpc_routes</td>
      <td></td>
      <td>A list of comma separated CIDRs to be filtered from the spoke VPC route table. When configured, filtering CIDR(s) or it’s subnet will be deleted from VPC routing tables as well as from spoke gateway’s routing table. Example: 10.2.0.0/116,10.3.0.0/16</td>
    </tr>  
    <tr><td></td><td></td><td></td><td></td><td></td>
      <td>included_advertised_spoke_routes</td>
      <td></td>
      <td>A list of comma separated CIDRs to be advertised to on-prem as Included CIDR List. When configured, it will replace all advertised routes from this VPC. Example: 10.4.0.0/116,10.5.0.0/16</td>
    </tr>  
    <tr><td></td><td></td><td class="gcp unsupported"></td><td class="oci unsupported"></td><td class="alibaba unsupported"></td>
      <td>subnet_pairs</td>
      <td>2</td>
      <td>Number of Public/Private subnet pairs created in the VPC.</td>
    </tr>  
    <tr><td></td><td></td><td class="gcp unsupported"></td><td class="oci unsupported"></td><td class="alibaba unsupported"></td>
      <td>subnet_size</td>
      <td>28</td>
      <td>Size of the Public/Private subnets in the VPC.</td>
    </tr>  
    <tr><td></td><td class="azure unsupported"></td><td class="gcp unsupported"></td><td class="oci unsupported"></td><td class="alibaba unsupported"></td>
      <td>enable_encrypt_volume</td>
      <td>false</td>
      <td>Set to true to enable EBS volume encryption for Gateway.</td>
    </tr>         
    <tr><td></td><td class="azure unsupported"></td><td class="gcp unsupported"></td><td class="oci unsupported"></td><td class="alibaba unsupported"></td>
      <td>customer_managed_keys</td>
      <td>null</td>
      <td>Customer managed key ID for EBS Volume encryption.</td>
    </tr>         
    <tr><td></td><td></td><td></td><td></td><td></td>
      <td>private_vpc_default_route</td>
      <td>false</td>
      <td>Program default route in VPC private route table.</td>
    </tr>   
    <tr><td></td><td></td><td></td><td></td><td></td>
      <td>skip_public_route_table_update</td>
      <td>false</td>
      <td>Skip programming VPC public route table.</td>
    </tr>   
    <tr><td></td><td></td><td></td><td></td><td></td>
      <td>auto_advertise_s2c_cidrs</td>
      <td>false</td>
      <td>Auto Advertise Spoke Site2Cloud CIDRs.</td>
    </tr>   
    <tr><td></td><td></td><td></td><td></td><td></td>
      <td>tunnel_detection_time</td>
      <td>null</td>
      <td>The IPsec tunnel down detection time for the Spoke Gateway in seconds. Must be a number in the range [20-600]. Default is 60.</td>
    </tr>   
    <tr><td></td><td></td><td class="gcp unsupported"></td><td class="oci unsupported"></td><td class="alibaba unsupported"></td>
      <td>tags</td>
      <td>null</td>
      <td>Map of tags to assign to the gateway.</td>
    </tr>   
    <tr><td></td><td></td><td></td><td></td><td></td>
      <td>use_existing_vpc</td>
      <td>false</td>
      <td>Set to true to use an existing VPC in stead of having this module create one.</td>
    </tr>        
    <tr><td></td><td></td><td></td><td></td><td></td>
      <td>vpc_id</td>
      <td></td>
      <td>VPC ID, for using an existing VPC.</td>
    </tr>  
    <tr><td></td><td></td><td></td><td></td><td></td>
      <td>gw_subnet</td>
      <td></td>
      <td>Subnet CIDR, for using an existing VPC. Required when use_existing_vpc is enabled. Make sure this is a public subnet.</td>
    </tr>  
    <tr><td></td><td></td><td></td><td></td><td></td>
      <td>hagw_subnet</td>
      <td></td>
      <td>Subnet CIDR, for using an existing VPC. Required when use_existing_vpc is enabled and ha_gw is true. Make sure this is a public subnet.</td>
    </tr>  
    <tr><td></td><td></td><td class="gcp unsupported"></td><td class="oci unsupported"></td><td class="alibaba unsupported"></td>
      <td>china</td>
      <td>false</td>
      <td>Set to true when deploying this module in mainland China regions</td>
    </tr>  
    <tr><td></td><td></td><td></td><td></td><td></td>
      <td>transit_gw_egress</td>
      <td></td>
      <td>Add secondary transit to attach spoke to (e.g. for dual transit firenet). When segmentation is used, transit_gw MUST be used for east/west transit.</td>
    </tr>  
    <tr><td></td><td></td><td></td><td></td><td></td>
      <td>transit_gw_route_tables</td>
      <td>[]</td>
      <td>A list of route tables to propagate routes to for transit_gw attachment.</td>
    </tr>  
    <tr><td></td><td></td><td></td><td></td><td></td>
      <td>transit_gw_egress_route_tables</td>
      <td>[]</td>
      <td>A list of route tables to propagate routes to for transit_gw_egress attachment.</td>
    </tr>  
    <tr><td></td><td></td><td></td><td></td><td></td>
      <td>inspection</td>
      <td>false</td>
      <td>Set to true to enable east/west Firenet inspection. Only valid when transit_gw is East/West transit Firenet</td>
    </tr>                                                                                                    
    <tr><td></td><td class="azure unsupported"></td><td class="gcp unsupported"></td><td class="oci unsupported"></td><td class="alibaba unsupported"></td>
      <td>gov</td>
      <td>false</td>
      <td>Set to true when deploying this module in AWS GOV</td>
    </tr>     
    <tr><td class="aws unsupported"></td><td></td><td class="gcp unsupported"></td><td class="oci unsupported"></td><td class="alibaba unsupported"></td>
      <td>az_support</td>
      <td>true</td>
      <td>Set to false if the region does not support Availability Zones.</td>
    </tr>     
    <tr><td class="aws unsupported"></td><td class="azure unsupported"></td><td></td><td class="oci unsupported"></td><td class="alibaba unsupported"></td>
      <td>ha_region</td>
      <td></td>
      <td>Region for multi region HA. HA is multi-az single region by default, but will become multi region when this is set</td>
    </tr>     
    <tr><td class="aws unsupported"></td><td class="azure unsupported"></td><td></td><td class="oci unsupported"></td><td class="alibaba unsupported"></td>
      <td>ha_cidr</td>
      <td></td>
      <td>The IP CIDR to be used to create ha_region spoke subnet. Only required when ha_region is set.</td>
    </tr>     
</table>

### Outputs
This module will return the following outputs:

key | description
:---|:---
vpc | The created VPC/VNET/VCN as an object with all of it's attributes (when use_existing_vnet is false). This was created using the aviatrix_vpc resource.
spoke_gateway | The created Aviatrix spoke gateway as an object with all of it's attributes.
