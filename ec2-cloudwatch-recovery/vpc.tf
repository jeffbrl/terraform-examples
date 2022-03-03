module "vpc" {

  source = "terraform-aws-modules/vpc/aws"

  name = "${var.env}-infra"

  cidr = "100.64.0.0/20"

  azs = ["${var.region}a", "${var.region}b"]

  enable_ipv6                                    = true
  assign_ipv6_address_on_creation                = true
  map_public_ip_on_launch                        = true
  private_subnet_assign_ipv6_address_on_creation = true

  enable_nat_gateway     = false
  create_egress_only_igw = false

  public_subnets  = ["100.64.0.0/24", "100.64.1.0/24"]
  private_subnets = ["100.64.2.0/24", "100.64.3.0/24"]

  public_subnet_ipv6_prefixes  = [0, 1]
  private_subnet_ipv6_prefixes = [2, 3]

  enable_dns_hostnames = true
  enable_dns_support   = true

  enable_flow_log = false

  tags = {
    Created_by  = "terraform"
    Environment = var.env
  }
}
