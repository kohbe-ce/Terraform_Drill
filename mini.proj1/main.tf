# 작업 계획
# 1. VPC 생성
#    * VPC 생성
#    * IGW 생성 및 연결
#
# 2. Public Subnet 생성 
#    * Public SN 생성
#    * Routing Table 생성 및 연결
#
# 3. EC2 인스턴스
#    * Security Group 생성
#    * SSH Key gen
#    * EC2 인스턴스 생성
#      - user_data -> docker 설치
#
# 4. 테스트
#    * SSH key를 통한 접속
#

#-------------------------------------#
# 1. VPC 생성
#    * VPC 생성
#    * IGW 생성 및 연결
#-------------------------------------#
resource "aws_vpc" "vpc1" {
  cidr_block = "10.0.0.0/16"
  instance_tenancy = "default"

  enable_dns_hostnames = true
  enable_dns_support = true

  tags ={
    Name = "vpc1"
  }
}

resource "aws_internet_gateway" "igw1" {
  vpc_id = aws_vpc.vpc1.id

  tags = {
    Name = "igw1"
    env = "dev"
  }
}

#-------------------------------------#
# 2. Public Subnet 생성 
#    * Public SN 생성
#    * Routing Table 생성
#    * RT에 Default Route 추가
#    * SN RT 연결
#-------------------------------------#
resource "aws_subnet" "vpc1-pubsn" {
  vpc_id     = aws_vpc.vpc1.id
  cidr_block = "10.0.1.0/24"

  tags = {
    Name = "vpc1-pubsn"
  }
}

resource "aws_route_table" "vpc1-igw1-rt" {
  vpc_id = aws_vpc.vpc1.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw1.id
  }

  tags = {
    Name = "vpc1-igw1-rt"
  }
}

resource "aws_route_table_association" "pubsn-rt-assoc" {
  subnet_id      = aws_subnet.vpc1-pubsn.id
  route_table_id = aws_route_table.vpc1-igw1-rt.id
}

#-------------------------------------#
# 3. EC2 인스턴스
#    * Security Group 생성
#    * SSH Key gen
#      - ssh-keygen -t rsa
#      -> $HOME/.ssh/kohbkey
#      -> empty password
#    * EC2 인스턴스 생성
#      - AMI data source
#      - user_data -> docker 설치
#-------------------------------------#
resource "aws_security_group" "allow_sg" {
  name        = "all-allow"
  description = "All Allow inbound traffic"
  vpc_id      = aws_vpc.vpc1.id

  ingress {
    description      = "ALL from VPC"
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  tags = {
    Name = "all-allow"
  }
}

resource "aws_key_pair" "kohbkey" {
  key_name   = "kohbkey"
  public_key = file("~/.ssh/kohbkey.pub")
}

data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"]
}

resource "aws_instance" "docker-server-dev" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t2.micro"

  associate_public_ip_address = true

  key_name = aws_key_pair.kohbkey.key_name
  subnet_id = aws_subnet.vpc1-pubsn.id
  vpc_security_group_ids = [aws_security_group.allow_sg.id]

  user_data = file("userdata.template")
  user_data_replace_on_change = true

  tags = {
    Name = "docker-server-dev"
  }

  provisioner "local-exec" {
    command = templatefile("linux-ssh-config.tftpl", {
      hostname = self.public_ip,
      identifyfile = "~/.ssh/kohbkey",
      user = "ubuntu"
    })
    interpreter = ["bash", "-c"]

  }
}








