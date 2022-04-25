output "http_api_endpoint" {
  description = "The default endpoint for the HTTP API"
  value       = aws_apigatewayv2_stage.lambda.invoke_url
}

output "lambda_runtime" {
  description = "The runtime of the Lambda function"
  value       = var.lambda_runtime
}
