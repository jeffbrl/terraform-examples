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

  tags = {
    Name = "terraform-tgw"
  }
}

resource "aws_ec2_transit_gateway_vpc_attachment" "vpc-one_tgw_attachment" {
  subnet_ids                                      = ["${module.vpc-one.public_subnets}"]
  transit_gateway_id                              = "${aws_ec2_transit_gateway.tgw.id}"
  vpc_id                                          = "${module.vpc-one.vpc_id}"
  transit_gateway_default_route_table_association = false

  tags = {
    Name = "vpc-one"
  }
}

resource "aws_ec2_transit_gateway_vpc_attachment" "vpc-two_tgw_attachment" {
  subnet_ids                                      = ["${module.vpc-two.private_subnets}"]
  transit_gateway_id                              = "${aws_ec2_transit_gateway.tgw.id}"
  vpc_id                                          = "${module.vpc-two.vpc_id}"
  transit_gateway_default_route_table_association = false

  tags = {
    Name = "vpc-two"
  }
}

resource "aws_ec2_transit_gateway_vpc_attachment" "vpc-three_tgw_attachment" {
  subnet_ids                                      = ["${module.vpc-three.private_subnets}"]
  transit_gateway_id                              = "${aws_ec2_transit_gateway.tgw.id}"
  vpc_id                                          = "${module.vpc-three.vpc_id}"
  transit_gateway_default_route_table_association = false

  tags = {
    Name = "vpc-three"
  }
}

resource "aws_ec2_transit_gateway_vpc_attachment" "vpc-four_tgw_attachment" {
  subnet_ids                                      = ["${module.vpc-four.private_subnets}"]
  transit_gateway_id                              = "${aws_ec2_transit_gateway.tgw.id}"
  vpc_id                                          = "${module.vpc-four.vpc_id}"
  transit_gateway_default_route_table_association = false

  tags = {
    Name = "vpc-four"
  }
}

# We will not use the default TGW route domain in this example

# Create TGW route domain for vpc-one to vpc-two connectivity
resource "aws_ec2_transit_gateway_route_table" "one_two" {
  transit_gateway_id = "${aws_ec2_transit_gateway.tgw.id}"

  tags = {
    Name = "one_two_rt"
  }
}

# Create TGW route domain for vpc-three to vpc-four connectivity
resource "aws_ec2_transit_gateway_route_table" "three_four" {
  transit_gateway_id = "${aws_ec2_transit_gateway.tgw.id}"

  tags = {
    Name = "three_four_rt"
  }
}

# associate vpc-one attachment to one_two route domain
resource "aws_ec2_transit_gateway_route_table_association" "tgw_association_vpc_one" {
  transit_gateway_attachment_id  = "${aws_ec2_transit_gateway_vpc_attachment.vpc-one_tgw_attachment.id}"
  transit_gateway_route_table_id = "${aws_ec2_transit_gateway_route_table.one_two.id}"
}

# associate vpc-two attachment to one_two route domain
resource "aws_ec2_transit_gateway_route_table_association" "tgw_association_vpc_two" {
  transit_gateway_attachment_id  = "${aws_ec2_transit_gateway_vpc_attachment.vpc-two_tgw_attachment.id}"
  transit_gateway_route_table_id = "${aws_ec2_transit_gateway_route_table.one_two.id}"
}

# associate vpc-three attachment to three_four route domain
resource "aws_ec2_transit_gateway_route_table_association" "tgw_association_vpc_three" {
  transit_gateway_attachment_id  = "${aws_ec2_transit_gateway_vpc_attachment.vpc-three_tgw_attachment.id}"
  transit_gateway_route_table_id = "${aws_ec2_transit_gateway_route_table.three_four.id}"
}

# associate vpc-four attachment to three_four route domain
resource "aws_ec2_transit_gateway_route_table_association" "tgw_association_vpc_four" {
  transit_gateway_attachment_id  = "${aws_ec2_transit_gateway_vpc_attachment.vpc-four_tgw_attachment.id}"
  transit_gateway_route_table_id = "${aws_ec2_transit_gateway_route_table.three_four.id}"
}

# Propagate the routes from the associations to the the appropriate route domains

resource "aws_ec2_transit_gateway_route_table_propagation" "vpc-one_propagation" {
  transit_gateway_attachment_id  = "${aws_ec2_transit_gateway_vpc_attachment.vpc-one_tgw_attachment.id}"
  transit_gateway_route_table_id = "${aws_ec2_transit_gateway_route_table.one_two.id}"
}

resource "aws_ec2_transit_gateway_route_table_propagation" "vpc-two_propagation" {
  transit_gateway_attachment_id  = "${aws_ec2_transit_gateway_vpc_attachment.vpc-two_tgw_attachment.id}"
  transit_gateway_route_table_id = "${aws_ec2_transit_gateway_route_table.one_two.id}"
}

resource "aws_ec2_transit_gateway_route_table_propagation" "vpc-three_propagation" {
  transit_gateway_attachment_id  = "${aws_ec2_transit_gateway_vpc_attachment.vpc-three_tgw_attachment.id}"
  transit_gateway_route_table_id = "${aws_ec2_transit_gateway_route_table.three_four.id}"
}

resource "aws_ec2_transit_gateway_route_table_propagation" "vpc-four_propagation" {
  transit_gateway_attachment_id  = "${aws_ec2_transit_gateway_vpc_attachment.vpc-four_tgw_attachment.id}"
  transit_gateway_route_table_id = "${aws_ec2_transit_gateway_route_table.three_four.id}"
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
