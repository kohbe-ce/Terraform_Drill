terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "5.25.0"
    }
  }
}

provider "aws" {
  region = "us-east-2"
}

#Instance 생성 + user_data
resource "aws_instance" "my-webserver" {
  ami           = "ami-0e83be366243f524a"
  instance_type = "t2.micro"

  vpc_security_group_ids = [aws_security_group.my-webserver-sg.id]

  user_data = <<-EOF
                #!/bin/bash
                apt -y install apache2
                systemctl enable --now apache2
                echo "hello, world" | sudo tee /var/www/html/index.html
                EOF

  user_data_replace_on_change = true

  tags = {
    Name = "my-webserver"
  }
}

# Security Group 생성
resource "aws_security_group" "my-webserver-sg" {
  name        = "my-webserver-sg"
  description = "Allow ssh, http inbound traffic"

  ingress {
    description      = "http from VPC"
    from_port        = 80
    to_port          = 80
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
    Name = "allow_ssh_tcp"
  }  
}
