# tflint-ignore: terraform_naming_convention - matching case of CloudFormation equivalent for testing purposes
output "HttpApiEndpoint" {
  description = "The default endpoint for the HTTP API"
  value       = aws_apigatewayv2_stage.lambda.invoke_url
}

# tflint-ignore: terraform_naming_convention - matching case of CloudFormation equivalent for testing purposes
output "LambdaRuntime" {
  description = "The runtime of the Lambda function"
  value       = var.lambda_runtime
}
