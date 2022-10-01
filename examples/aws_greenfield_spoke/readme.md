### Usage Example AWS Greenfield Spoke

In this example, the module does not only deploy the Aviatrix spoke gateways, but also creates the VPC itself.

```hcl
module "spoke_aws_1" {
  source  = "terraform-aviatrix-modules/mc-spoke/aviatrix"
  version = "1.3.2"

  cloud           = "AWS"
  name            = "App1"
  cidr            = "10.1.0.0/20"
  region          = "eu-west-1"
  account         = "AWS-Account"
  transit_gw      = "avx-eu-west-1-transit"
  security_domain = "blue"
}
```