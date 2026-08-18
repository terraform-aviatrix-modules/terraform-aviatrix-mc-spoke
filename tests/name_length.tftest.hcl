mock_provider "aviatrix" {}

variables {
  cloud            = "azure"
  region           = "West Europe"
  account          = "Azure"
  use_existing_vpc = true
  vpc_id           = "existing-vnet:existing-rg"
  gw_subnet        = "10.1.0.0/24"
  attached         = false
}

run "name_of_50_characters_is_accepted" {
  command = plan

  variables {
    name = "spoke-vnet-with-a-name-of-exactly-fifty-characters"
  }
}

run "name_longer_than_50_characters_is_rejected" {
  command = plan

  variables {
    name = "spoke-vnet-with-a-name-of-fiftyone-characters-total"
  }

  expect_failures = [var.name]
}
