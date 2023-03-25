resource "aws_launch_configuration" "this" {
  name            = "web launch configuration"
  image_id        = data.aws_ami.amazon_linux_2.id
  instance_type   = "t3.nano"
  security_groups = [module.vpc.default_security_group_id, aws_security_group.this.id]
  user_data       = file("user-data/webserver_user_data")

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "this" {
  name                 = random_pet.pet.id
  launch_configuration = aws_launch_configuration.this.name
  vpc_zone_identifier  = module.vpc.private_subnets
  min_size             = 2
  max_size             = 3

  //depends_on = [aws_lb.this]
}

resource "aws_autoscaling_attachment" "this" {
  autoscaling_group_name = aws_autoscaling_group.this.id
  lb_target_group_arn    = aws_lb_target_group.this.arn
}

resource "aws_security_group" "this" {
  name        = "AllowWebExternal-${random_pet.pet.id}"
  description = "Allow HTTPS inbound traffic"
  vpc_id      = module.vpc.vpc_id

  ingress {
    description      = "HTTPS"
    from_port        = 443
    to_port          = 443
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["0::0/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "AllowWebExternal-${random_pet.pet.id}"
  }
}
