output "user_message" {
  value = "aws lambda invoke --function-name ${aws_lambda_function.main.function_name} /tmp/out --log-type Tail --query 'LogResult' --output text --region ${var.aws_region} |  base64 -d"
}

