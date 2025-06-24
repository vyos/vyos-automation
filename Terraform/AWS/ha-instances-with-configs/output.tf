
output "vyos_01_public_ip" {
  value = aws_instance.vyos_01.public_ip
}

output "vyos_02_public_ip" {
  value = aws_instance.vyos_02.public_ip
}

output "data_vpc_instance_public_ip" {
  value = aws_instance.data_vpc_instance.public_ip
}

output "ssh_command_for_vyos_01" {
  value = "ssh -i keys/vyos_lab_private_key.pem vyos@${aws_instance.vyos_01.public_ip}"
}

output "ssh_command_for_vyos_02" {
  value = "ssh -i keys/vyos_lab_private_key.pem vyos@${aws_instance.vyos_02.public_ip}"
}

output "ssh_command_for_data_vpc_instance" {
  value = "ssh -i keys/vyos_lab_private_key.pem ec2-user@${aws_instance.data_vpc_instance.public_ip}"
}