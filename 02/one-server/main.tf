provider "aws" {
  region = "us-east-2"
}

resource "aws_instance" "example" {
  ami = "ami-06d4b7182ac3480fa"
  instance_type = "t2.micro"
    tags = {
    Name = "terraform-example"
  }
}



