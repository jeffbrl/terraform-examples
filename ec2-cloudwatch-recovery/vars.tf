variable "env" {
  default = "dev"
}

variable "region" {
  default = "us-east-2"
}

variable "ssh_key" {

}

variable "comparison_operator" {
  default = "GreaterThanOrEqualToThreshold"
}

variable "evaluation_periods" {
  default = "1"
}

variable "period" {
  default = "300"
}

variable "statistic" {
  default = "Maximum"
}

variable "threshold" {
  default = "1"
}

variable "alarm_description" {
  default = "Auto recover the EC2 instance if Status Check fails."
}

variable "sns_topic_name" {
  default = "EC2Recovery"
}

variable "email_address" {

}
