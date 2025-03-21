
resource "aws_launch_template" "web" {
  name          = "${random_string.suffix.result}-web"
  image_id      = data.aws_ami.al2023.id

  vpc_security_group_ids = [module.vpc.default_security_group_id]

  user_data = base64encode(file("user-data/webserver_user_data"))

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "asg" {
  name                 = "${random_string.suffix.result}-web"
  launch_template {
    id      = aws_launch_template.web.id
    version = "$Latest"
  }
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
