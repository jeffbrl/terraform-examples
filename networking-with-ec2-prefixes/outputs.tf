output "vpc" {
  value = module.vpc.vpc_id
}

output "docker_host_dns" {
  value = aws_eip.this.public_dns
}

output "docker_eni" {
  value = aws_network_interface.docker_eni.id
}
