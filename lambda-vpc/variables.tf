variable "aws_region" {
  default = "us-east-2"
}

variable "name" {}

variable "cidr_range" {
  default = "10.10.0.0/16"
}

variable "public_subnets" {
  default = ["10.10.0.0/24", "10.10.1.0/24"]
}

variable "private_subnets" {
  default = ["10.10.100.0/24", "10.10.101.0/24"]
}

variable "availability_zones" {
  default = [ "us-east-2a", "us-east-2b" ]
}
