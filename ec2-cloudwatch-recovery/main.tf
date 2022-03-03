resource "aws_cloudwatch_metric_alarm" "this" {

  alarm_name          = "Web-StatusCheckFailed_System"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = var.evaluation_periods
  metric_name         = "StatusCheckFailed_System"
  namespace           = "AWS/EC2"
  period              = var.period
  statistic           = var.statistic

  dimensions = {
    InstanceId = aws_instance.web.id
  }

  alarm_actions     = ["arn:aws:automate:${var.region}:ec2:recover", aws_sns_topic.this.arn]
  threshold         = var.threshold
  alarm_description = var.alarm_description
}

data "aws_ami" "amazon_linux_2" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "owner-alias"
    values = ["amazon"]
  }

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-2.0.????????-x86_64-gp2"]
  }

  filter {
    name   = "state"
    values = ["available"]
  }
}

resource "aws_network_interface" "this" {
  subnet_id       = module.vpc.private_subnets[0]
  private_ips     = ["100.64.2.100"]
  security_groups = [module.vpc.default_security_group_id]

  tags = {
    Name = "primary_network_interface"
  }
}

resource "aws_instance" "web" {
  ami           = data.aws_ami.amazon_linux_2.id
  instance_type = "t3.nano"
  key_name      = var.ssh_key

  network_interface {
    network_interface_id = aws_network_interface.this.id
    device_index         = 0
  }

  tags = {
    Name = "web"
  }
}

resource "aws_sns_topic" "this" {
  name = var.sns_topic_name
}

resource "aws_sns_topic_subscription" "this" {
  topic_arn = aws_sns_topic.this.arn
  protocol  = "email"
  endpoint  = var.email_address
}
