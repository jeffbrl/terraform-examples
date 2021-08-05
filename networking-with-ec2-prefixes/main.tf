provider "aws" {
  region = var.aws_region

  skip_metadata_api_check     = true
  skip_get_ec2_platforms      = true
  skip_region_validation      = true
  skip_credentials_validation = true

}

resource "random_pet" "this" {
  length = 2
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

data "aws_ami" "ubuntu" {
  most_recent = true
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
  owners = ["099720109477"] # Canonical
}

data "template_file" "public_user_data" {
  template = file("user-data/public_user_data.tpl")

  vars = {
    private_key_contents = file("mykey")
    public_key_contents  = file("mykey.pub")
  }
}

data "template_file" "docker_user_data" {
  template = file("user-data/docker_user_data.tpl")

  vars = {
    private_key_contents = file("mykey")
    public_key_contents  = file("mykey.pub")
  }
}

resource "aws_security_group" "ssh_in" {
  name        = "bastion-${random_pet.this.id}"
  description = "permit"
  vpc_id      = module.vpc.vpc_id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.management_ip]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["0::/0"]
  }

  tags = {
    Name = "bastion-${random_pet.this.id}"
  }
}

resource "aws_eip" "this" {
  network_interface = aws_network_interface.docker_eni.id
  vpc               = true
}

resource "aws_security_group" "docker" {
  name        = "docker-${random_pet.this.id}"
  description = "permit"
  vpc_id      = module.vpc.vpc_id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.management_ip]
  }

  ingress {
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["0::/0"]
  }

  tags = {
    Name = "docker-${random_pet.this.id}"
  }
}

resource "aws_network_interface" "docker_eni" {
  subnet_id          = module.vpc.public_subnets[0]
  source_dest_check  = false
  security_groups    = [aws_security_group.docker.id, module.vpc.default_security_group_id]
  ipv6_address_count = 1

  tags = {
    Name = "docker-${random_pet.this.id}"
  }
}

/*
resource "aws_instance" "bastion" {
  ami                         = data.aws_ami.ubuntu.id
  instance_type               = "t3.nano"
  associate_public_ip_address = true
  subnet_id                   = module.vpc.public_subnets[0]
  security_groups             = [aws_security_group.ssh_in.id, module.vpc.default_security_group_id]
  user_data                   = data.template_file.public_user_data.rendered

  tags = {
    Name = "bastion-${random_pet.this.id}"
  }
}
*/

resource "aws_instance" "docker" {
  ami           = data.aws_ami.amazon_linux_2.id
  instance_type = "t3.nano"
  user_data     = data.template_file.docker_user_data.rendered
  key_name      = "jeffkey"
  network_interface {
    network_interface_id = aws_network_interface.docker_eni.id
    device_index         = 0
  }

  tags = {
    Name = "docker-${random_pet.this.id}"
  }

}

resource "null_resource" "ec2_prefix_assignment_v6" {
  provisioner "local-exec" {
    command = "aws ec2 assign-ipv6-addresses --network-interface-id ${aws_network_interface.docker_eni.id} --ipv6-prefix-count=1 --region us-east-1 --output json > /tmp/ipv6"
  }
}

resource "null_resource" "ec2_prefix_assignment_v4" {
  provisioner "local-exec" {
    command = "aws ec2 assign-private-ip-addresses --network-interface-id ${aws_network_interface.docker_eni.id} --ipv4-prefix-count=1 --region us-east-1 --output json > /tmp/ipv4"
  }
}


