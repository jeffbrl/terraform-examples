module "vpc-west" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "2.17.0"

  name = "terraform-vpc-west"

  cidr = "10.0.0.0/16"

  azs            = ["us-east-1a", "us-east-1b"]
  public_subnets = ["10.0.0.0/24", "10.0.1.0/24"]

  enable_dns_hostnames = true
  enable_dns_support   = true
}

module "vpc-east" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "2.17.0"

  name = "terraform-vpc-east"

  cidr = "10.1.0.0/16"

  azs            = ["us-east-1a", "us-east-1b"]
  public_subnets = ["10.1.0.0/24", "10.1.1.0/24"]

  enable_dns_hostnames = true
  enable_dns_support   = true
}

resource "aws_vpc_peering_connection" "pc" {
  peer_vpc_id = module.vpc-west.vpc_id
  vpc_id      = module.vpc-east.vpc_id
  auto_accept = true

  accepter {
    allow_remote_vpc_dns_resolution = true
  }

  requester {
    allow_remote_vpc_dns_resolution = true
  }

  tags = {
    Name = "vpc-east to vpc-west VPC peering"
  }
}

resource "aws_route" "vpc-peering-route-east" {
  count                     = 2
  route_table_id            = module.vpc-east.public_route_table_ids[0]
  destination_cidr_block    = module.vpc-west.public_subnets_cidr_blocks[count.index]
  vpc_peering_connection_id = aws_vpc_peering_connection.pc.id
}

resource "aws_route" "vpc-peering-route-west" {
  count                     = 2
  route_table_id            = module.vpc-west.public_route_table_ids[0]
  destination_cidr_block    = module.vpc-east.public_subnets_cidr_blocks[count.index]
  vpc_peering_connection_id = aws_vpc_peering_connection.pc.id
}

