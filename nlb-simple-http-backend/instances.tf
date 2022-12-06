resource "aws_instance" "web_instances" {
  ami   = data.aws_ami.amazon_linux_2.id
  count = 2

  instance_type               = "t3.nano"
  associate_public_ip_address = false
  key_name = var.ssh_key
  subnet_id                   = module.vpc.private_subnets[count.index]
  security_groups             = [aws_security_group.management_internal.id, aws_security_group.webserver.id ]


  user_data = file("user-data/webserver_user_data")

  tags = {
    Name = "webservers",
    Role = "Backend"
  }
}

resource "aws_instance" "bastion" {
  ami   = data.aws_ami.amazon_linux_2.id

  instance_type               = "t3.nano"
  associate_public_ip_address = true
  key_name = var.ssh_key
  subnet_id                   = module.vpc.public_subnets[0]
  security_groups             = [aws_security_group.management_external.id]

  tags = {
    Name = "bastion",
    Role = "management"
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
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "management_external" {
  name        = "permit-mgmt-external"
  description = "Permit mgmt traffic from trusted IPs"
  vpc_id      = module.vpc.vpc_id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.management_prefix]
  } 
  egress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/16"]
  } 
}

resource "aws_security_group" "management_internal" {
  name        = "permit-mgmt-internal"
  description = "Permit mgmt traffic from internal IPs"
  vpc_id      = module.vpc.vpc_id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/16"]
  } 
}