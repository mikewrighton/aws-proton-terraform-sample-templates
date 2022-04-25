# Copy+paste and rename to `terraform.tfvars` for working locally
service_name = "terraform-test-service"

codebuild_deployments = {
  foo = {}
  two = {
    name = "bar"
  }
}

repository_connection_arn = "arn:aws:codecommit:us-east-1:123456789012:my-repository"
repository_id             = "my-repository"
