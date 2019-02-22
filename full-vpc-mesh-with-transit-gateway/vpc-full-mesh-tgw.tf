module "vpc-one" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "1.53.0"

  name = "terraform-vpc-one"

  cidr = "10.1.0.0/16"

  azs = ["ap-northeast-1a", "ap-northeast-1c"]

  public_subnets       = ["10.1.0.0/24", "10.1.1.0/24"]
  enable_dns_hostnames = true
  enable_dns_support   = true
}

module "vpc-two" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "1.53.0"

  name = "terraform-vpc-two"

  cidr = "10.2.0.0/16"

  azs = ["ap-northeast-1a", "ap-northeast-1c"]

  private_subnets      = ["10.2.0.0/24", "10.2.1.0/24"]
  enable_dns_hostnames = true
  enable_dns_support   = true
}

module "vpc-three" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "1.53.0"

  name = "terraform-vpc-three"

  cidr = "10.3.0.0/16"

  azs = ["ap-northeast-1a", "ap-northeast-1c"]

  private_subnets      = ["10.3.0.0/24", "10.3.1.0/24"]
  enable_dns_hostnames = true
  enable_dns_support   = true
}

module "vpc-four" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "1.53.0"

  name = "terraform-vpc-four"

  cidr = "10.4.0.0/16"
  azs  = ["ap-northeast-1a", "ap-northeast-1c"]

  private_subnets      = ["10.4.0.0/24", "10.4.1.0/24"]
  enable_dns_hostnames = true
  enable_dns_support   = true
}

resource "aws_ec2_transit_gateway" "tgw" {
  auto_accept_shared_attachments = "enable"
}

resource "aws_ec2_transit_gateway_vpc_attachment" "vpc-one_tgw_attachment" {
  subnet_ids         = ["${module.vpc-one.public_subnets}"]
  transit_gateway_id = "${aws_ec2_transit_gateway.tgw.id}"
  vpc_id             = "${module.vpc-one.vpc_id}"
}

resource "aws_ec2_transit_gateway_vpc_attachment" "vpc-two_tgw_attachment" {
  subnet_ids         = ["${module.vpc-two.private_subnets}"]
  transit_gateway_id = "${aws_ec2_transit_gateway.tgw.id}"
  vpc_id             = "${module.vpc-two.vpc_id}"
}

resource "aws_ec2_transit_gateway_vpc_attachment" "vpc-three_tgw_attachment" {
  subnet_ids         = ["${module.vpc-three.private_subnets}"]
  transit_gateway_id = "${aws_ec2_transit_gateway.tgw.id}"
  vpc_id             = "${module.vpc-three.vpc_id}"
}

resource "aws_ec2_transit_gateway_vpc_attachment" "vpc-four_tgw_attachment" {
  subnet_ids         = ["${module.vpc-four.private_subnets}"]
  transit_gateway_id = "${aws_ec2_transit_gateway.tgw.id}"
  vpc_id             = "${module.vpc-four.vpc_id}"
}

resource "aws_route" "tgw-route-one" {
  route_table_id         = "${module.vpc-one.public_route_table_ids[0]}"
  destination_cidr_block = "10.0.0.0/8"
  transit_gateway_id     = "${aws_ec2_transit_gateway.tgw.id}"
}

resource "aws_route" "tgw-route-two" {
  route_table_id         = "${module.vpc-two.private_route_table_ids[0]}"
  destination_cidr_block = "10.0.0.0/8"
  transit_gateway_id     = "${aws_ec2_transit_gateway.tgw.id}"
}

resource "aws_route" "tgw-route-three" {
  route_table_id         = "${module.vpc-three.private_route_table_ids[0]}"
  destination_cidr_block = "10.0.0.0/8"
  transit_gateway_id     = "${aws_ec2_transit_gateway.tgw.id}"
}

resource "aws_route" "tgw-route-four" {
  route_table_id         = "${module.vpc-four.private_route_table_ids[0]}"
  destination_cidr_block = "10.0.0.0/8"
  transit_gateway_id     = "${aws_ec2_transit_gateway.tgw.id}"
}
