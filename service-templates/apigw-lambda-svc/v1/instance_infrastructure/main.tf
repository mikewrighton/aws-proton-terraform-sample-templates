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
    archive = {
      source  = "hashicorp/archive"
      version = "~> 2.0"
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
