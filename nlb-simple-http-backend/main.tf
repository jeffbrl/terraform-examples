
resource "random_string" "suffix" {
  length  = 8
  special = false
}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"

  name               = "NLB-TF-${random_string.suffix.result}"
  cidr               = "10.0.0.0/16"
  azs                = [data.aws_availability_zones.available.names[0], data.aws_availability_zones.available.names[1]]
  public_subnets     = ["10.0.1.0/24", "10.0.2.0/24"]
  private_subnets    = ["10.0.10.0/24", "10.0.20.0/24"]
  enable_nat_gateway = false
}

module "vpc_endpoints" {
  source = "terraform-aws-modules/vpc/aws//modules/vpc-endpoints"

  vpc_id             = module.vpc.vpc_id
  security_group_ids = [module.vpc.default_security_group_id]

  endpoints = {
    s3 = {
      service = "s3",
      tags    = { Name = "s3-vpc-endpoint" }
      service_type    = "Gateway"
      route_table_ids = flatten([module.vpc.intra_route_table_ids, module.vpc.private_route_table_ids, module.vpc.public_route_table_ids])
    }
  }
}

resource "aws_lb" "nlb" {
  name               = "NLB1-TF-${random_string.suffix.result}"
  internal           = false
  load_balancer_type = "network"
 
  subnets            = [module.vpc.public_subnets[0], module.vpc.public_subnets[1]]

  enable_deletion_protection = false

  tags = {
    Environment = "production"
  }
}

resource "aws_lb_target_group" "TCP_TG" {
  name     = "NLB1-TG-TF-${random_string.suffix.result}"
  port     = 80
  protocol = "TCP"
  vpc_id   = module.vpc.vpc_id
  health_check {
    healthy_threshold   = "3"
    unhealthy_threshold = "3"
    timeout             = "2"
    interval            = "5"
    protocol            = "HTTP"
    matcher             = "200"
    path                = "/"
  }
}

resource "aws_lb_listener" "tcp" {
  load_balancer_arn = aws_lb.nlb.arn
  port              = 80
  protocol          = "TCP"

  default_action {
    target_group_arn = aws_lb_target_group.TCP_TG.arn
    type             = "forward"
  }
}

resource "aws_lb_target_group_attachment" "instance_attach1" {
  target_group_arn = aws_lb_target_group.TCP_TG.arn
  target_id        = aws_instance.web_instances[0].id
  port             = 80
}

resource "aws_lb_target_group_attachment" "instance_attach2" {
  target_group_arn = aws_lb_target_group.TCP_TG.arn
  target_id        = aws_instance.web_instances[1].id
  port             = 80
}

