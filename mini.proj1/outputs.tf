output "ec2-pubip" {
  description = "EC2 Instance's Public IP"
  value = aws_instance.docker-server-dev.public_ip
}
