################################################################################
# Terraform Backend & Provider
################################################################################

terraform {
  required_version = ">= 0.13.1"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }

  # backend "s3" {}
}

provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      "proton:pipeline" = var.service_name
    }
  }
}

################################################################################
# Common Data Sources & Local Variables
################################################################################

data "aws_region" "current" {}
data "aws_caller_identity" "current" {}

locals {
  account_id = data.aws_caller_identity.current.account_id
  region     = data.aws_region.current.id
}
