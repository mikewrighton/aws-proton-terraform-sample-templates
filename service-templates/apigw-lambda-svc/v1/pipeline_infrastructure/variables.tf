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

variable "lambda_runtime" {
  description = "Lambda runtime"
  type        = string
  default     = "nodejs12.x"
}

variable "function_account_ids" {
  description = "Account IDs that require access to the function artifacts"
  type        = list(string)
  default     = []
}

variable "codebuild_deployments" {
  description = "CodeBuild deployment projects"
  type        = any
  default     = {}
}

variable "pipeline_code_directory" {
  description = "Directory where the pipeline code is located"
  type        = string
  default     = "lambda-ping-sns"
}

variable "pipeline_unit_test_command" {
  description = "Command to run unit tests"
  type        = string
  default     = "echo 'add your unit test command here'"
}

variable "pipeline_packaging_command" {
  description = "Command to run packaging"
  type        = string
  default     = "zip function.zip app.js"
}

variable "repository_connection_arn" {
  description = "Connection ARN for the repository"
  type        = string
  default     = ""
}

variable "repository_id" {
  description = "ID of the repository"
  type        = string
  default     = ""
}

variable "repository_branch_name" {
  description = "Branch name of the repository"
  type        = string
  default     = "main"
}
