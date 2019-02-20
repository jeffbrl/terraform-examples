data "template_file" "user_data" {
  template = "${file("user-data.tpl")}"

  vars = {
    private_key_contents = "${file("mykey")}"
  }
}

resource "aws_security_group" "vpc-one-ssh-in" {
  name   = "allow-ssh-sg"
  vpc_id = "${module.vpc-one.vpc_id}"

  ingress {
    cidr_blocks = [
      "0.0.0.0/0",
    ]

    from_port = 22
    to_port   = 22
    protocol  = "tcp"
  }
}

resource "aws_security_group" "vpc-two-ping-ssh-in" {
  name   = "allow-ping-ssh-sg"
  vpc_id = "${module.vpc-two.vpc_id}"

  ingress {
    cidr_blocks = [
      "0.0.0.0/0",
    ]

    from_port = 22
    to_port   = 22
    protocol  = "tcp"
  }

  ingress {
    cidr_blocks = [
      "0.0.0.0/0",
    ]

    from_port = -1
    to_port   = -1
    protocol  = "icmp"
  }
}

resource "aws_security_group" "vpc-three-ping-ssh-in" {
  name   = "allow-ping-ssh-sg"
  vpc_id = "${module.vpc-three.vpc_id}"

  ingress {
    cidr_blocks = [
      "0.0.0.0/0",
    ]

    from_port = 22
    to_port   = 22
    protocol  = "tcp"
  }

  ingress {
    cidr_blocks = [
      "0.0.0.0/0",
    ]

    from_port = -1
    to_port   = -1
    protocol  = "icmp"
  }
}

resource "aws_security_group" "vpc-four-ping-ssh-in" {
  name   = "allow-ping-ssh-sg"
  vpc_id = "${module.vpc-four.vpc_id}"

  ingress {
    cidr_blocks = [
      "0.0.0.0/0",
    ]

    from_port = 22
    to_port   = 22
    protocol  = "tcp"
  }

  ingress {
    cidr_blocks = [
      "0.0.0.0/0",
    ]

    from_port = -1
    to_port   = -1
    protocol  = "icmp"
  }
}

resource "aws_key_pair" "terraform-tgw-ssh-keypair" {
  key_name   = "terraform-tgw-ssh-keypair"
  public_key = "${file("mykey.pub")}"
}

resource "aws_instance" "vpc-one-bastion" {
  ami                         = "${var.ubuntu_ami}"
  instance_type               = "t2.micro"
  associate_public_ip_address = true
  subnet_id                   = "${module.vpc-one.public_subnets[0]}"
  security_groups             = ["${aws_security_group.vpc-one-ssh-in.id}", "${module.vpc-one.default_security_group_id}"]
  key_name                    = "${aws_key_pair.terraform-tgw-ssh-keypair.key_name}"
  user_data                   = "${data.template_file.user_data.rendered}"

  tags = {
    Name = "vpc-one-bastion"
  }
}

resource "aws_instance" "vpc-two-test" {
  ami = "${var.ubuntu_ami}"

  instance_type   = "t2.micro"
  subnet_id       = "${module.vpc-two.private_subnets[0]}"
  key_name        = "${aws_key_pair.terraform-tgw-ssh-keypair.key_name}"
  security_groups = ["${aws_security_group.vpc-two-ping-ssh-in.id}", "${module.vpc-two.default_security_group_id}"]
  private_ip      = "10.2.0.10"
  user_data       = "${data.template_file.user_data.rendered}"

  tags = {
    Name = "vpc-two-test"
  }
}

resource "aws_instance" "vpc-three-test" {
  ami             = "${var.ubuntu_ami}"
  instance_type   = "t2.micro"
  subnet_id       = "${module.vpc-three.private_subnets[0]}"
  key_name        = "${aws_key_pair.terraform-tgw-ssh-keypair.key_name}"
  security_groups = ["${aws_security_group.vpc-three-ping-ssh-in.id}", "${module.vpc-three.default_security_group_id}"]
  private_ip      = "10.3.0.10"
  user_data       = "${data.template_file.user_data.rendered}"

  tags = {
    Name = "vpc-three-test"
  }
}

resource "aws_instance" "vpc-four-test" {
  ami             = "${var.ubuntu_ami}"
  instance_type   = "t2.micro"
  key_name        = "${aws_key_pair.terraform-tgw-ssh-keypair.key_name}"
  security_groups = ["${aws_security_group.vpc-four-ping-ssh-in.id}", "${module.vpc-four.default_security_group_id}"]
  subnet_id       = "${module.vpc-four.private_subnets[0]}"
  private_ip      = "10.4.0.10"
  user_data       = "${data.template_file.user_data.rendered}"

  tags = {
    Name = "vpc-four-test"
  }
}
