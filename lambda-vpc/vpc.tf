module "vpc" {

  version = "2.64.0"
  source  = "terraform-aws-modules/vpc/aws"

  name = "${var.name}-vpc"

  cidr = var.cidr_range

  azs = var.availability_zones

  private_subnet_assign_ipv6_address_on_creation = false

  public_subnets  = var.public_subnets
  private_subnets = var.private_subnets

  enable_dns_hostnames = true
  enable_dns_support   = true
}

