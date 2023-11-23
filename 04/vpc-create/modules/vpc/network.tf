##### VPC 생성 #####
resource "aws_vpc" "main" {
  cidr_block           = var.myvpc-cidr
  instance_tenancy     = var.myvpc-tenancy
  enable_dns_hostnames = true
  tags                 = var.my-tags
}

##### Subnet 생성 #####
resource "aws_subnet" "main" {
  vpc_id     = var.mysubnet-vpcid
  cidr_block = var.mysubnet-cidr

  tags = var.my-tags
}

