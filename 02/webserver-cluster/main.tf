#---------------------------------------
#
# Webserver Cluster 구축 계획
#
#---------------------------------------
# VPC - default
# + Internet Gateway
#
# Subnet - default
# + Routing Table
#
# ELB(ALB) - ASG(EC2 count: 2~10)
# 1. ASG
#   - Start Templet
#   - ASG 구성
# 1. ELB(ALB)
#   - LB 구성
#   - listener + listenr rule
#   - target group
#---------------------------------------



#---------------------------------------#
# VPC - default
# + Internet Gateway
#
# Subnet - default
# + Routing Table
#---------------------------------------#

data "aws_vpc" "default-vpc" {
  default = true
}

data "aws_subnets" "default-subnet" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default-vpc.id]
  }
}


#---------------------------------------#
# 1. ASG
#   - SecurityGroup 구성
#   - 시작 구성(구 버전 방식 현재는 시작 템플릿으로 진행)
#   - ASG 구성
#---------------------------------------#
resource "aws_security_group" "lb-launch-config-sg" {
  name        = "lb-launch-config-sg"
  description = "Allow 8080/tcp inbound traffic"

  ingress {
    description      = "8080/TCP from VPC"
    from_port        = var.backend-port
    to_port          = var.backend-port
    protocol         = "tcp"
    cidr_blocks      = var.cidr_blocks
 }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }
  tags = {
    Name = "lb-launch-config-sg"
  }
}
resource "aws_launch_configuration" "lb-launch-conifg" {
  name          = "web_launch_configuration"
  image_id      = "ami-0fb653ca2d3203ac1"
  instance_type = "t2.micro"
  security_groups = [aws_security_group.lb-launch-config-sg.id]
  user_data = <<-EOF
              #!/bin/bash
              echo "<center><h1>Hello, World</h1></center>" > index.html
              nohup busybox httpd -f -p 8080 &
              EOF
  lifecycle {
    create_before_destroy = true
  }# 반복적 코드 작동 시 필요.

}

resource "aws_autoscaling_group" "myasg" {

  max_size           = 10
  min_size           = 2
  health_check_type = "ELB"
  launch_configuration = aws_launch_configuration.lb-launch-conifg.name
  vpc_zone_identifier = data.aws_subnets.default-subnet.ids

  target_group_arns = [aws_lb_target_group.my-alb-tg.arn]
  depends_on = [aws_lb_target_group.my-alb-tg]
}

#---------------------------------------#
# 2. ELB(ALB)
#   - target group
#   - LB 구성
#   - Listener + Listenr Rule
#---------------------------------------#

resource "aws_lb_target_group" "my-alb-tg" {
  name     = "my-alb-tg"
  port     = var.backend-port
  protocol = "HTTP"
  vpc_id   = data.aws_vpc.default-vpc.id
}


resource "aws_security_group" "alb-sg" {
  name        = "alb-sg"
  description = "Allow 80/tcp inbound traffic"

  ingress {
    description      = "80/TCP from VPC"
    from_port        = var.frontend-port
    to_port          = var.frontend-port
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
 }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }
  tags = {
    Name = "alb-sg"
  }
}

resource "aws_lb" "my-alb" {
  name               = "my-alb"
  internal           = false
  load_balancer_type = "application"

  security_groups    = [aws_security_group.alb-sg.id]
  subnets            = data.aws_subnets.default-subnet.ids

  tags = {
    Environment = "dev"
  }
}

resource "aws_lb_listener" "frontend" {
  load_balancer_arn = aws_lb.my-alb.arn
  port              = var.frontend-port
  protocol          = "HTTP"

  default_action {
    type = "fixed-response"

    fixed_response {
      content_type = "text/plain"
      message_body = "404 not found"
      status_code  = "404"
    }
  }
}

resource "aws_lb_listener_rule" "health_check" {
  listener_arn = aws_lb_listener.frontend.arn
  priority     = 100

  condition {
    path_pattern {
      values = ["*"]
    }
  }

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.my-alb-tg.arn
  }

}
