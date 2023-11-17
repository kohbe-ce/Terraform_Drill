
variable "backend-port" {
  description = "Back End Web Server Port Number"
  type = number
  default = 8080
}

variable "cidr_blocks" {
  description = "CIDR Blocks"
  type = list(string)
  default = ["0.0.0.0/0"]
}

variable "frontend-port" {
  description = "Front End Web Page Port Number"
  type = number
  default = 80
}

variable "default_region" {
  description = "AWS Default Region"
  type = string
  default = "us-east-2"
}
