variable "aws_region" {
  default = "us-east-1"
}

variable "instance_size" {
  description = "AWS EC2 instance size"
  type        = string
}
