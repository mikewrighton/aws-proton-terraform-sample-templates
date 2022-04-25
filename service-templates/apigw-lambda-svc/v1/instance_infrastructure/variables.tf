variable "aws_region" {
  description = "Region where resources will be provisioned"
  type        = string
  default     = "us-east-1"
}

variable "service_name" {
  description = "Name of the service"
  type        = string
  default     = "apigw-lambda-svc"
}

variable "lambda_function_name" {
  description = "Name of the Lambda function"
  type        = string
  default     = "function1"
}

variable "lambda_runtime" {
  description = "Runtime of the Lambda function"
  type        = string
  default     = "nodejs12.x"
}

variable "lambda_handler" {
  description = "Handler of the Lambda function"
  type        = string
  default     = "index.handler"
}

variable "use_local_function" {
  description = "Determines whether to use a local function archive (`true`) or external stored in S3 (`false`)"
  type        = bool
  default     = true
}

variable "lambda_s3_bucket" {
  description = "S3 bucket where Lambda function code is stored"
  type        = string
  default     = ""
}

variable "lambda_s3_key" {
  description = "S3 key where Lambda function code is stored"
  type        = string
  default     = ""
}

variable "sns_topic_name" {
  description = "Name of the SNS topic"
  type        = string
  default     = ""
}

variable "sns_topic_arn" {
  description = "SNS topic ARN"
  type        = string
  default     = ""
}
