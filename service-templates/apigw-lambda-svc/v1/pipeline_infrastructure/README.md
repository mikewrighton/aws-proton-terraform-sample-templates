# Pipeline

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

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 0.13.1 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 4.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | ~> 4.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_codebuild_project.build](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/codebuild_project) | resource |
| [aws_codebuild_project.deploy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/codebuild_project) | resource |
| [aws_codepipeline.pipeline](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/codepipeline) | resource |
| [aws_iam_policy.build](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_policy.deploy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_policy.pipeline](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_policy.pipeline_action](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_role.build](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role.deploy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role.pipeline](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role.pipeline_action](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy_attachment.build](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.deploy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.pipeline](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.pipeline_action](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_kms_alias.pipeline_artifacts](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kms_alias) | resource |
| [aws_kms_key.pipeline_artifacts](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kms_key) | resource |
| [aws_s3_bucket.function](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket) | resource |
| [aws_s3_bucket.pipeline_artifacts](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket) | resource |
| [aws_s3_bucket_policy.function](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_policy) | resource |
| [aws_s3_bucket_public_access_block.pipeline_artifacts](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_public_access_block) | resource |
| [aws_s3_bucket_server_side_encryption_configuration.function](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_server_side_encryption_configuration) | resource |
| [aws_s3_bucket_server_side_encryption_configuration.pipeline_artifacts](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_server_side_encryption_configuration) | resource |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_iam_policy_document.build](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.deploy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.function](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.pipeline](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.pipeline_action](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.pipeline_artifacts_kms](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_region.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_aws_region"></a> [aws\_region](#input\_aws\_region) | Region where resources will be provisioned | `string` | `"us-east-1"` | no |
| <a name="input_codebuild_deployments"></a> [codebuild\_deployments](#input\_codebuild\_deployments) | CodeBuild deployment projects | `any` | `{}` | no |
| <a name="input_function_account_ids"></a> [function\_account\_ids](#input\_function\_account\_ids) | Account IDs that require access to the function artifacts | `list(string)` | `[]` | no |
| <a name="input_lambda_runtime"></a> [lambda\_runtime](#input\_lambda\_runtime) | Lambda runtime | `string` | `"nodejs12.x"` | no |
| <a name="input_pipeline_code_directory"></a> [pipeline\_code\_directory](#input\_pipeline\_code\_directory) | Directory where the pipeline code is located | `string` | `"lambda-ping-sns"` | no |
| <a name="input_pipeline_packaging_command"></a> [pipeline\_packaging\_command](#input\_pipeline\_packaging\_command) | Command to run packaging | `string` | `"zip function.zip app.js"` | no |
| <a name="input_pipeline_unit_test_command"></a> [pipeline\_unit\_test\_command](#input\_pipeline\_unit\_test\_command) | Command to run unit tests | `string` | `"echo 'add your unit test command here'"` | no |
| <a name="input_repository_branch_name"></a> [repository\_branch\_name](#input\_repository\_branch\_name) | Branch name of the repository | `string` | `"main"` | no |
| <a name="input_repository_connection_arn"></a> [repository\_connection\_arn](#input\_repository\_connection\_arn) | Connection ARN for the repository | `string` | `""` | no |
| <a name="input_repository_id"></a> [repository\_id](#input\_repository\_id) | ID of the repository | `string` | `""` | no |
| <a name="input_service_name"></a> [service\_name](#input\_service\_name) | Name of the service | `string` | `"apigw-lambda-svc"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_pipeline_endpoint"></a> [pipeline\_endpoint](#output\_pipeline\_endpoint) | CodePipeline endpoint URL |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
