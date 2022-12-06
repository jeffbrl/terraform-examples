output "bastion_ip" {
    value = aws_instance.bastion.public_ip
}

output "nlb_ip" {
    value = aws_lb.nlb.dns_name
}