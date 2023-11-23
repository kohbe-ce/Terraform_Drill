variable "region" {
  description = "Default Region"
  type        = string
  default     = "us-east-2"
}

variable "myvpc-cidr" {
  description = "MyVPC CIDR Block"
  type        = string
  default     = "10.0.0.0/16"
}

variable "myvpc-tenancy" {
  description = "Instance Tenancy in My VPC: default|dedicated"
  type        = string
  default     = "default"
}

variable "my-tags" {
  description = "My tags"
  type        = map(string)
  default = {
    Name = "main"
  }
}

variable "mysubnet-vpcid" {
  description = "My Subnet VPC ID"
  type        = string
}

variable "mysubnet-cidr" {
  description = "My Subnet CIDR Block"
  type        = string
  default     = "10.0.1.0/24"
}
