# Instance

## Local Development & Testing

Copy the provided `example.terraform.tfvars` locally and rename to `terraform.tfvars`.

Add, update, modify any variables required for testing within the `terraform.tfvars` file.

Provision the resources using:

```bash
$ terraform init
$ terraform plan
$ terraform apply
```
Note that this example may create resources which cost money. Run `terraform destroy` when you no longer need these resources.

```
<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 0.13.1 |
| <a name="requirement_archive"></a> [archive](#requirement\_archive) | ~> 2.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 4.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_archive"></a> [archive](#provider\_archive) | ~> 2.0 |
| <a name="provider_aws"></a> [aws](#provider\_aws) | ~> 4.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_apigatewayv2_api.lambda](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/apigatewayv2_api) | resource |
| [aws_apigatewayv2_integration.lambda](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/apigatewayv2_integration) | resource |
| [aws_apigatewayv2_route.function](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/apigatewayv2_route) | resource |
| [aws_apigatewayv2_stage.lambda](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/apigatewayv2_stage) | resource |
| [aws_cloudwatch_log_group.api_gw](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_group) | resource |
| [aws_iam_policy.sns](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_role.function](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy_attachment.lambda_basic_execution](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.sns](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_lambda_function.function](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lambda_function) | resource |
| [aws_lambda_permission.function](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lambda_permission) | resource |
| [archive_file.function](https://registry.terraform.io/providers/hashicorp/archive/latest/docs/data-sources/file) | data source |
| [aws_iam_policy_document.sns](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_aws_region"></a> [aws\_region](#input\_aws\_region) | Region where resources will be provisioned | `string` | `"us-east-1"` | no |
| <a name="input_lambda_function_name"></a> [lambda\_function\_name](#input\_lambda\_function\_name) | Name of the Lambda function | `string` | `"function1"` | no |
| <a name="input_lambda_handler"></a> [lambda\_handler](#input\_lambda\_handler) | Handler of the Lambda function | `string` | `"index.handler"` | no |
| <a name="input_lambda_runtime"></a> [lambda\_runtime](#input\_lambda\_runtime) | Runtime of the Lambda function | `string` | `"nodejs12.x"` | no |
| <a name="input_lambda_s3_bucket"></a> [lambda\_s3\_bucket](#input\_lambda\_s3\_bucket) | S3 bucket where Lambda function code is stored | `string` | `""` | no |
| <a name="input_lambda_s3_key"></a> [lambda\_s3\_key](#input\_lambda\_s3\_key) | S3 key where Lambda function code is stored | `string` | `""` | no |
| <a name="input_service_name"></a> [service\_name](#input\_service\_name) | Name of the service | `string` | `"apigw-lambda-svc"` | no |
| <a name="input_sns_topic_arn"></a> [sns\_topic\_arn](#input\_sns\_topic\_arn) | SNS topic ARN | `string` | `""` | no |
| <a name="input_sns_topic_name"></a> [sns\_topic\_name](#input\_sns\_topic\_name) | Name of the SNS topic | `string` | `""` | no |
| <a name="input_use_local_function"></a> [use\_local\_function](#input\_use\_local\_function) | Determines whether to use a local function archive (`true`) or external stored in S3 (`false`) | `bool` | `true` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_http_api_endpoint"></a> [http\_api\_endpoint](#output\_http\_api\_endpoint) | The default endpoint for the HTTP API |
| <a name="output_lambda_runtime"></a> [lambda\_runtime](#output\_lambda\_runtime) | The runtime of the Lambda function |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
