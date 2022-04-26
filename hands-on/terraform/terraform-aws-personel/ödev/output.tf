output "instance_public_ip" {
  value = aws_instance.hw-ec2.*.public_ip

}


