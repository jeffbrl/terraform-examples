resource "random_uuid" "uuid" {
}

module "vpc" {
  version = "2.21.0"

  source = "terraform-aws-modules/vpc/aws"

  name = "terraform-vpc-${random_uuid.uuid.result}"

  cidr = var.cidr_range

  azs = var.availability_zones

  public_subnets  = var.public_subnets
  private_subnets = var.private_subnets

  enable_dns_hostnames = true
  enable_dns_support   = true
  enable_s3_endpoint   = var.enable_s3_endpoint
}

