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

  owners = ["099720109477"] # Canonical
}

resource "aws_instance" "web" {
  count         = var.ec2_count
  ami           = var.ami_id_ubuntu2004
  instance_type = var.instance_type
  subnet_id     = var.subnet_id
  tags          = var.instance_tag
}