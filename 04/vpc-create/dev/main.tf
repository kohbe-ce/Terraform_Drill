##### Terraform Configuration #####
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.26.0"
    }
  }
}

##### Provider Configuration #####
provider "aws" {
  # Configuration options
  region = "us-east-2"
}

##### Module - myvpc #####
module "myvpc" {
  source = "../modules/vpc"
  myvpc-cidr = "192.168.0.0/24"
  my-tags = {Name = "main"}
  mysubnet-vpcid = module.myvpc.vpc-id
  mysubnet-cidr = "192.168.0.0/25"
}

##### Module - myEC2 #####
module "my_ec2" {
  source = "../modules/ec2"

  ec2_count = 1
  # ami_id_ubuntu2004 = "ami-0c6e5afdd23291f73"
  # instance_type = "t2.micro"
  subnet_id = module.myvpc.subnet-id
}
