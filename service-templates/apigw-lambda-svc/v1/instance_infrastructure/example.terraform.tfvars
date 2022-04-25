# Copy+paste and rename to `terraform.tfvars` for working locally
service_name         = "terraform-test-service"
lambda_function_name = "terraform-test-function"

sns_topic_name = "terraform-test-topic"
sns_topic_arn  = "aws:sns:us-east-1:123456789012:${var.sns_topic_name}"
