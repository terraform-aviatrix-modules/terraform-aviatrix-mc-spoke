variable "region" {
  default = "eu-west-1"
}

variable "name" {
  default = "Spoke1"
}

variable "gw_subnet" {
  default = "100.64.1.0/24"
}

variable "vpc_cidr" {
  default = "10.0.0.0/22"
}

#Create VPC
resource "aws_vpc" "this" {
  cidr_block = var.vpc_cidr

  tags = {
    Name = var.name
  }
}

#Add secondary CIDR
resource "aws_vpc_ipv4_cidr_block_association" "this" {
  vpc_id     = aws_vpc.this.id
  cidr_block = var.gw_subnet
}

#Create route tables
resource "aws_route_table" "this" {
  for_each = toset(["gateway1", "gateway2", "internal1", "internal2", "public1", "public2"])
  vpc_id   = aws_vpc.this.id

  tags = {
    Name = format("%s-%s", var.name, each.value)
  }
}

#Create IGW
resource "aws_internet_gateway" "this" {
  vpc_id = aws_vpc.this.id

  tags = {
    Name = format("%s-igw", var.name)
  }
}

#Install default route in public route tables
resource "aws_route" "this" {
  #Filter route tables that are internal
  for_each = { for k, v in aws_route_table.this : k => v if length(regexall("internal.*", k)) == 0 }

  route_table_id         = each.value.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.this.id
}

#Define subnet parameters in a local variable
locals {
  subnets = {
    gateway1 = {
      route_table       = "gateway1",
      cidr              = cidrsubnet(var.gw_subnet, 1, 0)
      availability_zone = "a"
    },
    gateway2 = {
      route_table       = "gateway2",
      cidr              = cidrsubnet(var.gw_subnet, 1, 1)
      availability_zone = "b"
    },
    private1 = {
      route_table       = "internal1",
      cidr              = cidrsubnet(var.vpc_cidr, 4, 0)
      availability_zone = "a"
    },
    private2 = {
      route_table       = "internal1",
      cidr              = cidrsubnet(var.vpc_cidr, 4, 1)
      availability_zone = "a"
    },
    private3 = {
      route_table       = "internal2",
      cidr              = cidrsubnet(var.vpc_cidr, 4, 2)
      availability_zone = "b"
    },
    private4 = {
      route_table       = "internal2",
      cidr              = cidrsubnet(var.vpc_cidr, 4, 3)
      availability_zone = "b"
    },
    public1 = {
      route_table       = "public1",
      cidr              = cidrsubnet(var.vpc_cidr, 4, 4)
      availability_zone = "a"
    },
    public2 = {
      route_table       = "public1",
      cidr              = cidrsubnet(var.vpc_cidr, 4, 5)
      availability_zone = "a"
    },
    public3 = {
      route_table       = "public2",
      cidr              = cidrsubnet(var.vpc_cidr, 4, 6)
      availability_zone = "b"
    },
    public4 = {
      route_table       = "public2",
      cidr              = cidrsubnet(var.vpc_cidr, 4, 7)
      availability_zone = "b"
    },
  }
}

#Create all subnets
resource "aws_subnet" "this" {
  for_each   = local.subnets
  vpc_id     = aws_vpc.this.id
  cidr_block = each.value.cidr

  tags = {
    Name = each.key
  }

  depends_on = [
    aws_vpc_ipv4_cidr_block_association.this
  ]
}

#Associate all subnets with designated route tables
resource "aws_route_table_association" "this" {
  for_each = local.subnets

  subnet_id      = aws_subnet.this[each.key].id
  route_table_id = aws_route_table.this[each.value.route_table].id
}

#Create Aviatrix spoke resources
module "spoke_aws_1" {
  source  = "terraform-aviatrix-modules/mc-spoke/aviatrix"
  version = "1.6.6"

  cloud            = "AWS"
  name             = "App1"
  region           = "eu-west-1"
  account          = "AWS"
  transit_gw       = "avx-eu-west-1-transit"
  network_domain   = "blue"
  use_existing_vpc = true
  vpc_id           = aws_vpc.this.id
  gw_subnet        = aws_subnet.this["gateway1"].cidr_block
  hagw_subnet      = aws_subnet.this["gateway2"].cidr_block
}
