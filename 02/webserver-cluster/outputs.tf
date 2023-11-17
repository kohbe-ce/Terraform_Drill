output "alb-dns-name" {
  description = "External Loadbalancer DNS Name"
  value = aws_lb.my-alb.dns_name
}
