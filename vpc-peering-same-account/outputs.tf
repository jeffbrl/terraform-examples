output vpc-west {
  value = "${module.vpc-west.vpc_id}"
}

output vpc-east {
  value = "${module.vpc-east.vpc_id}"
}

output vpc_peering_connection {
  value = "${aws_vpc_peering_connection.pc.id}"
}
