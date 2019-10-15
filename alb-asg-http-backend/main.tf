
resource "random_string" "suffix" {
  length  = 8
  special = false
}

resource "aws_security_group" "alb_sg" {
  name        = "ALB_SG_TF"
  description = "ALB SG"
  vpc_id      = module.vpc.vpc_id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "allow_all"
  }
}

resource "aws_security_group" "webserver" {
  name        = "webservers_sg_tf"
  description = "ALB SG"
  vpc_id      = module.vpc.vpc_id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/16"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/16"]
  }
}


module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 2.0"

  name               = "ALB-TF-${random_string.suffix.result}"
  cidr               = "10.0.0.0/16"
  azs                = [data.aws_availability_zones.available.names[0], data.aws_availability_zones.available.names[1]]
  public_subnets     = ["10.0.1.0/24", "10.0.2.0/24"]
  private_subnets    = ["10.0.10.0/24", "10.0.20.0/24"]
  enable_nat_gateway = false
  enable_s3_endpoint = true
}

resource "aws_lb" "alb" {
  name               = "ALB1-TF-${random_string.suffix.result}"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_sg.id, module.vpc.default_security_group_id]
  subnets            = [module.vpc.public_subnets[0], module.vpc.public_subnets[1]]

  enable_deletion_protection = false

  tags = {
    Environment = "production"
  }
}

resource "aws_lb_target_group" "HTTP_TG" {
  name     = "ALB1-TG-TF-${random_string.suffix.result}"
  port     = 80
  protocol = "HTTP"
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

resource "aws_alb_listener" "http" {
  load_balancer_arn = aws_lb.alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    target_group_arn = aws_lb_target_group.HTTP_TG.arn
    type             = "forward"
  }
}

#Autoscaling Attachment
resource "aws_autoscaling_attachment" "asg_attach" {
  alb_target_group_arn   = aws_lb_target_group.HTTP_TG.arn
  autoscaling_group_name = aws_autoscaling_group.asg.id
}
