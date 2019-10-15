resource "aws_launch_configuration" "web-lc" {
  name            = "web launch configuration"
  image_id        = data.aws_ami.amazon_linux_2.id
  instance_type   = "t2.micro"
  security_groups = [module.vpc.default_security_group_id]
  user_data       = file("user-data/webserver_user_data")

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "asg" {
  name                 = "webservers_asg"
  launch_configuration = aws_launch_configuration.web-lc.name
  vpc_zone_identifier  = module.vpc.private_subnets
  min_size             = 2
  max_size             = 3

  depends_on = [aws_lb.alb]

  /*
  lifecycle {
    create_before_destroy = true
  }
*/
  tag {
    key                 = "Name"
    value               = "webserver"
    propagate_at_launch = true
  }

  tag {
    key                 = "Tool"
    value               = "Terraform"
    propagate_at_launch = true
  }
}
