output "vpc" {
  value = module.vpc.vpc_id
}

output "public_instance_ids" {
  value = aws_instance.public_instances.*.id
}

output "private_instance_ids" {
  value = aws_instance.private_instances.*.id
}

output "public_instances_ipv4_address" {
  value = aws_instance.public_instances.*.public_ip
}

output "private_instances_ipv4_address" {
  value = aws_instance.private_instances.*.private_ip
}

