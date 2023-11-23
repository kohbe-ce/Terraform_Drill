output "vpc-id" {
  description = "output : VPC ID "
  value       = aws_vpc.main.id
}

output "subnet-id" {
  description = "output : Subnet ID"
  value       = aws_subnet.main.id
}
