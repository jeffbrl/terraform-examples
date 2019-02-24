output vpc-one {
  value = "${module.vpc-one.vpc_id}"
}

output vpc-two {
  value = "${module.vpc-two.vpc_id}"
}

output vpc-three {
  value = "${module.vpc-three.vpc_id}"
}

output vpc-four {
  value = "${module.vpc-four.vpc_id}"
}

output bastion-public-ip {
  value = "${aws_instance.vpc-one-bastion.public_ip}"
}

output vpc-two-instance-private-ip {
  value = "${aws_instance.vpc-two-test.private_ip}"
}

output vpc-three-instance-private-ip {
  value = "${aws_instance.vpc-three-test.private_ip}"
}

output vpc-four-instance-private-ip {
  value = "${aws_instance.vpc-four-test.private_ip}"
}
