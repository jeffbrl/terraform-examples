resource "aws_instance" "web_instances" {
  ami   = data.aws_ami.amazon_linux_2.id
  count = 2

  instance_type               = var.instance_size
  associate_public_ip_address = false
  subnet_id                   = module.vpc.private_subnets[count.index]
  security_groups             = [module.vpc.default_security_group_id]


  user_data = file("user-data/webserver_user_data")

  tags = {
    Name = "webservers",
    Role = "Backend"
  }
}

