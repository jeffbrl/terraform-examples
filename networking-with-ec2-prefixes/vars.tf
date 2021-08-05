variable "aws_region" {
  default = "us-east-1"
}

// AZs must match aws_region
variable "availability_zones" {
  default = ["us-east-1a", "us-east-1b"]
}

variable "env" {
  default = "dev"
}

variable "vpc_cidr" {
  default = "100.64.0.0/16"
}

variable "public_subnets" {
  default = ["100.64.0.0/24", "100.64.1.0/24"]
}

variable "private_subnets" {
  default = ["100.64.100.0/24", "100.64.101.0/24"]
}

variable "management_ip" {}

locals {
  s3_bucket_name            = "vpc-flow-logs-to-s3-${var.env}-${random_pet.this.id}"
  cloudwatch_log_group_name = "vpc-flow-logs-to-cloudwatch-${var.env}-${random_pet.this.id}"
}


