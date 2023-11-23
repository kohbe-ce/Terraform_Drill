variable "ec2_count" {
  description = "EC2 count"
  type        = number
  default     = 2
}

variable "ami_id_ubuntu2004" {
  description = "(Seoul Region) Ubuntu 20.04 AMI ID"
  type        = string
  default     = "ami-0c6e5afdd23291f73"
}

variable "instance_type" {
  description = "(Free tier) Instance Type"
  type        = string
  default     = "t2.micro"
}

variable "subnet_id" {
  description = "Subnet ID"
  type        = string
}

variable "instance_tag" {
  description = "Instance tags"
  type        = map(string)
  default = {
    Name = "Main"
  }
}
