# tools/qa/versions.tf
terraform {
  required_providers {
    aviatrix = {
      source  = "aviatrix.com/aviatrix/aviatrix"
      version = ">= 99.0.0"
    }
  }
  required_version = ">= 1.2"
}
