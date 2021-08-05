module "vpc" {

  source = "terraform-aws-modules/vpc/aws"

  name = "${var.env}-infra"

  cidr = var.vpc_cidr

  azs = ["${var.aws_region}a", "${var.aws_region}b"]

  enable_ipv6                                    = true
  assign_ipv6_address_on_creation                = true
  map_public_ip_on_launch                        = true
  private_subnet_assign_ipv6_address_on_creation = true

  enable_nat_gateway     = false
  single_nat_gateway     = true
  create_egress_only_igw = false

  public_subnets  = var.public_subnets
  private_subnets = var.private_subnets

  public_subnet_ipv6_prefixes  = [0, 1]
  private_subnet_ipv6_prefixes = [2, 3]

  enable_dns_hostnames = true
  enable_dns_support   = true

  enable_flow_log = true

  flow_log_destination_type = "s3"
  flow_log_destination_arn  = module.s3_bucket.s3_bucket_arn
  flow_log_traffic_type     = "ALL"

  tags = {
    Created_by  = "terraform"
    Environment = var.env
  }
}

module "vpc_endpoints" {
  source = "terraform-aws-modules/vpc/aws//modules/vpc-endpoints"

  vpc_id = module.vpc.vpc_id

  endpoints = {

    s3 = {
      service         = "s3"
      service_type    = "Gateway"
      route_table_ids = flatten([module.vpc.intra_route_table_ids, module.vpc.private_route_table_ids, module.vpc.public_route_table_ids])

    }
  }
}

module "s3_bucket" {
  source = "terraform-aws-modules/s3-bucket/aws"

  bucket        = local.s3_bucket_name
  policy        = data.aws_iam_policy_document.flow_log_s3.json
  force_destroy = true

  tags = {
    Name = "vpc-flow-logs-s3-bucket-${var.env}-${random_pet.this.id}"
  }
}

data "aws_iam_policy_document" "flow_log_s3" {
  statement {
    sid = "AWSLogDeliveryWrite"

    principals {
      type        = "Service"
      identifiers = ["delivery.logs.amazonaws.com"]
    }

    effect = "Allow"

    actions = [
      "s3:PutObject",
    ]

    resources = ["arn:aws:s3:::${local.s3_bucket_name}/AWSLogs/*"]
  }

  statement {
    sid = "AWSLogDeliveryAclCheck"

    principals {
      type        = "Service"
      identifiers = ["delivery.logs.amazonaws.com"]
    }

    effect = "Allow"

    actions = [
      "s3:GetBucketAcl",
    ]

    resources = ["arn:aws:s3:::${local.s3_bucket_name}"]
  }
}
