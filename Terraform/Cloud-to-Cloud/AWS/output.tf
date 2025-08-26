
output "vyos_public_ip" {
  value = aws_instance.vyos.public_ip
}

output "ssh_command_for_vyos" {
  value = "ssh -i keys/vyos_lab_private_key.pem vyos@${aws_instance.vyos.public_ip}"
}

output "ssh_command_for_amazon_ec2" {
  value = "ssh -i keys/vyos_lab_private_key.pem ec2-user@${aws_instance.amazon_ec2_instance.public_ip}"
}
