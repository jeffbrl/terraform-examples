variable "aws_region" {
  default = "us-east-2"
}

variable "cidr_range" {
  default = "10.0.0.0/16"
}

# Note - number of AZs must match the number of public/private subnets

variable "availability_zones" {
  default = ["us-east-2a", "us-east-2b"]
}

variable "public_subnets" {
  default = ["10.0.0.0/24", "10.0.1.0/24"]
}

variable "private_subnets" {
  default = ["10.0.100.0/24", "10.0.101.0/24"]
}

variable "public_instance_count" {
  default = 2
}

variable "private_instance_count" {
  default = 2
}

variable "enable_s3_endpoint" {
  default = true
}
