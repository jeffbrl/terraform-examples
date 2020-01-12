
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


data "template_file" "public_user_data" {
  template = file("user-data/public_user_data.tpl")

  vars = {
    private_key_contents = file("mykey")
  }
}

data "template_file" "private_user_data" {
  template = file("user-data/private_user_data.tpl")

  vars = {
    private_key_contents = file("mykey")
  }
}

resource "aws_security_group" "ssh_in" {
  description = "Highly insecure SG permitting SSH"
  name        = "allow-ssh-sg"
  vpc_id      = module.vpc.vpc_id

  ingress {
    cidr_blocks = [
      "0.0.0.0/0",
    ]

    from_port = 22
    to_port   = 22
    protocol  = "tcp"
  }
}

resource "aws_key_pair" "ssh_keypair" {
  key_name   = "terraform-${random_uuid.uuid.result}"
  public_key = file("mykey.pub")
}

resource "aws_instance" "public_instances" {
  count                       = var.public_instance_count
  ami                         = data.aws_ami.amazon_linux_2.id
  instance_type               = "t3.nano"
  associate_public_ip_address = true
  subnet_id                   = module.vpc.public_subnets[count.index]
  security_groups             = [aws_security_group.ssh_in.id, module.vpc.default_security_group_id]
  key_name                    = aws_key_pair.ssh_keypair.key_name
  user_data                   = data.template_file.public_user_data.rendered

  tags = {
    Name = "tf-public-${count.index}"
  }
}

resource "aws_instance" "private_instances" {
  count                       = var.private_instance_count
  ami                         = data.aws_ami.amazon_linux_2.id
  instance_type               = "t3.nano"
  associate_public_ip_address = false
  subnet_id                   = module.vpc.private_subnets[count.index]
  security_groups             = [aws_security_group.ssh_in.id, module.vpc.default_security_group_id]
  key_name                    = aws_key_pair.ssh_keypair.key_name
  user_data                   = data.template_file.private_user_data.rendered

  tags = {
    Name = "tf-private-${count.index}"
  }
}

