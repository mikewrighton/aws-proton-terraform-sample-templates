################################################################################
# HTTI API
################################################################################

resource "aws_apigatewayv2_api" "lambda" {
  name          = var.service_name
  protocol_type = "HTTP"

  cors_configuration {
    allow_origins = ["*"]
    allow_methods = [
      "GET",
      "HEAD",
      "OPTIONS",
      "POST",
    ]
  }
}

resource "aws_apigatewayv2_stage" "lambda" {
  api_id = aws_apigatewayv2_api.lambda.id

  name        = "serverless_lambda_stage"
  auto_deploy = true

  access_log_settings {
    destination_arn = aws_cloudwatch_log_group.api_gw.arn

    format = jsonencode({
      requestId               = "$context.requestId"
      sourceIp                = "$context.identity.sourceIp"
      requestTime             = "$context.requestTime"
      protocol                = "$context.protocol"
      httpMethod              = "$context.httpMethod"
      resourcePath            = "$context.resourcePath"
      routeKey                = "$context.routeKey"
      status                  = "$context.status"
      responseLength          = "$context.responseLength"
      integrationErrorMessage = "$context.integrationErrorMessage"
    })
  }
}

resource "aws_cloudwatch_log_group" "api_gw" {
  name = "/aws/api_gw/${aws_apigatewayv2_api.lambda.name}"

  retention_in_days = 30
}

################################################################################
# HTTP Integration & Routes
################################################################################

resource "aws_apigatewayv2_integration" "lambda" {
  api_id = aws_apigatewayv2_api.lambda.id

  integration_uri    = aws_lambda_function.function.invoke_arn
  integration_type   = "AWS_PROXY"
  integration_method = "POST"
}

resource "aws_apigatewayv2_route" "function" {
  api_id = aws_apigatewayv2_api.lambda.id

  route_key = "$default"
  target    = "integrations/${aws_apigatewayv2_integration.lambda.id}"
}

################################################################################
# Lambda Function
################################################################################

data "archive_file" "function" {
  count = var.use_local_function ? 1 : 0

  type        = "zip"
  output_path = "${path.module}/function.zip"

  source {
    filename = "index.js"
    content  = file("${path.module}/lambdas/function.js")
  }
}

resource "aws_lambda_function" "function" {
  function_name = var.lambda_function_name
  runtime       = var.lambda_runtime
  role          = aws_iam_role.function.arn

  environment {
    variables = {
      SnsTopicName = var.sns_topic_name
    }
  }

  handler   = var.lambda_handler
  s3_bucket = var.use_local_function ? null : var.lambda_s3_bucket
  s3_key    = var.use_local_function ? null : var.lambda_s3_key
  filename  = var.use_local_function ? data.archive_file.function[0].output_path : null
}

resource "aws_lambda_permission" "function" {
  source_arn = "${aws_apigatewayv2_api.lambda.execution_arn}/*/*"

  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.function.function_name
  principal     = "apigateway.amazonaws.com"
}

resource "aws_iam_role" "function" {
  name_prefix = "serverless_lambda"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_basic_execution" {
  role       = aws_iam_role.function.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

data "aws_iam_policy_document" "sns" {
  statement {
    actions   = ["sns:Publish"]
    resources = [var.sns_topic_arn]
  }
}

resource "aws_iam_policy" "sns" {
  policy = data.aws_iam_policy_document.sns.json
}

resource "aws_iam_role_policy_attachment" "sns" {
  role       = aws_iam_role.function.name
  policy_arn = aws_iam_policy.sns.arn
}
