### Usage Example AWS Existing VPC Spoke

In this example, the module deploys the Aviatrix spoke gateways in an existing VPC.

```hcl
module "spoke_aws_1" {
  source  = "terraform-aviatrix-modules/mc-spoke/aviatrix"
  version = "8.0.1"

  cloud            = "AWS"
  name             = "App1"
  region           = "eu-west-1"
  account          = "AWS-Account"
  transit_gw       = "avx-eu-west-1-transit"
  network_domain  = "blue"
  use_existing_vpc = true
  vpc_id           = data.aws_vpc.example.vpc_id
  gw_subnet        = data.aws_subnet.example_gw.cidr_block
  hagw_subnet      = data.aws_subnet.example_hagw.cidr_block #Use separate subnets in multiple AZ's for gw and hagw, for multi AZ availability.
}
```