################################################################################
# S3 Bucket - Function
################################################################################

resource "aws_s3_bucket" "function" {
  bucket_prefix = "function-bucket"
}

resource "aws_s3_bucket_server_side_encryption_configuration" "function" {
  bucket = aws_s3_bucket.function.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_policy" "function" {
  count = length(var.function_account_ids) > 0 ? 1 : 0

  policy = data.aws_iam_policy_document.function.json
  bucket = aws_s3_bucket.function.id
}

data "aws_iam_policy_document" "function" {
  statement {
    principals {
      type        = "AWS"
      identifiers = [for id in var.function_account_ids : "arn:aws:iam::${id}:root"]
    }
    actions = [
      "s3:GetObject"
    ]
  }
}

################################################################################
# S3 Bucket - Pipeline Artifacts
################################################################################

resource "aws_s3_bucket" "pipeline_artifacts" {
  bucket_prefix = "pipeline-artifacts-bucket"
}

resource "aws_s3_bucket_public_access_block" "pipeline_artifacts" {
  bucket                  = aws_s3_bucket.pipeline_artifacts.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_server_side_encryption_configuration" "pipeline_artifacts" {
  bucket = aws_s3_bucket.pipeline_artifacts.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = "aws:kms"
      kms_master_key_id = aws_kms_key.pipeline_artifacts.arn
    }
  }
}

################################################################################
# KMS Key - Pipeline Artifact
################################################################################

resource "aws_kms_key" "pipeline_artifacts" {
  policy = data.aws_iam_policy_document.pipeline_artifacts_kms.json
}

resource "aws_kms_alias" "pipeline_artifacts" {
  target_key_id = aws_kms_key.pipeline_artifacts.id
  name          = "alias/codepipeline-encryption-key-${var.service_name}"
}

data "aws_iam_policy_document" "pipeline_artifacts_kms" {
  statement {
    sid = "KeyAdmin"

    actions = [
      "kms:Create*",
      "kms:Describe*",
      "kms:Enable*",
      "kms:List*",
      "kms:Put*",
      "kms:Update*",
      "kms:Revoke*",
      "kms:Disable*",
      "kms:Get*",
      "kms:Delete*",
      "kms:ScheduleKeyDeletion",
      "kms:CancelKeyDeletion",
      "kms:GenerateDataKey",
      "kms:TagResource",
      "kms:UntagResource"
    ]

    resources = ["*"]

    principals {
      identifiers = ["arn:aws:iam::${local.account_id}:root"]
      type        = "AWS"
    }
  }

  statement {
    sid = "KeyUsage"

    actions = [
      "kms:Decrypt",
      "kms:DescribeKey",
      "kms:Encrypt",
      "kms:ReEncrypt*",
      "kms:GenerateDataKey*"
    ]

    resources = ["*"]

    principals {
      identifiers = [
        aws_iam_role.build.arn,
        aws_iam_role.deploy.arn,
        aws_iam_role.pipeline.arn
      ]
      type = "AWS"
    }
  }
}

################################################################################
# IAM Role - Build
################################################################################

resource "aws_iam_role" "build" {
  name_prefix = "build-role"

  assume_role_policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Principal" : {
          "Service" : "codebuild.amazonaws.com"
        },
        "Action" : "sts:AssumeRole"
      }
    ]
  })
}

data "aws_iam_policy_document" "build" {
  statement {
    effect = "Allow"
    resources = [
      "arn:aws:logs:${local.region}:${local.account_id}:log-group:/aws/codebuild/${aws_codebuild_project.build.name}",
      "arn:aws:logs:${local.region}:${local.account_id}:log-group:/aws/codebuild/${aws_codebuild_project.build.name}*"
    ]
    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]
  }
  statement {
    effect = "Allow"
    resources = [
      "arn:aws:codebuild:${local.region}:${local.account_id}:report-group:/${aws_codebuild_project.build.name}*",
    ]
    actions = [
      "codebuild:CreateReportGroup",
      "codebuild:CreateReport",
      "codebuild:UpdateReport",
      "codebuild:BatchPutTestCases"
    ]
  }
  statement {
    effect    = "Allow"
    resources = ["*"]
    actions   = ["proton:GetService"]
  }
  statement {
    effect = "Allow"
    resources = [
      aws_s3_bucket.function.arn,
      "${aws_s3_bucket.function.arn}/*"
    ]
    actions = [
      "s3:GetObject*",
      "s3:GetBucket*",
      "s3:List*",
      "s3:DeleteObject*",
      "s3:PutObject*",
      "s3:Abort*",
      "s3:CreateMultipartUpload"
    ]
  }
  statement {
    effect = "Allow"
    resources = [
      aws_s3_bucket.pipeline_artifacts.arn,
      "${aws_s3_bucket.pipeline_artifacts.arn}*"
    ]
    actions = [
      "s3:GetObject*",
      "s3:GetBucket*",
      "s3:List*",
      "s3:DeleteObject*",
      "s3:PutObject*",
      "s3:Abort*"
    ]
  }
  statement {
    effect    = "Allow"
    resources = [aws_kms_key.pipeline_artifacts.arn]
    actions = [
      "kms:Decrypt",
      "kms:DescribeKey",
      "kms:Encrypt",
      "kms:ReEncrypt*",
      "kms:GenerateDataKey*"
    ]
  }
}

resource "aws_iam_policy" "build" {
  policy = data.aws_iam_policy_document.build.json
}

resource "aws_iam_role_policy_attachment" "build" {
  policy_arn = aws_iam_policy.build.arn
  role       = aws_iam_role.build.name
}

################################################################################
# CodeBuild Project - Build
################################################################################

locals {
  # Lookup map that converts shorthand syntax to expanded form CodePipeline accepts
  buildspec_runtime = {
    "ruby2.7" = {
      "ruby" = "2.7"
    },
    "nodejs12.x" = {
      "nodejs" = "12.x"
    },
    "python3.8" = {
      "python" = "3.8"
    },
    "java11" = {
      "java" = "openjdk11.x"
    },
    "dotnetcore3.1" = {
      "dotnet" = "3.1"
    }
  }
}

resource "aws_codebuild_project" "build" {
  name         = "${var.service_name}-build-project"
  service_role = aws_iam_role.build.arn

  encryption_key = aws_kms_key.pipeline_artifacts.arn

  artifacts {
    type = "CODEPIPELINE"
  }

  environment {
    compute_type                = "BUILD_GENERAL1_SMALL"
    image                       = "aws/codebuild/amazonlinux2-x86_64-standard:3.0"
    type                        = "LINUX_CONTAINER"
    image_pull_credentials_type = "CODEBUILD"

    environment_variable {
      name  = "bucket_name"
      value = aws_s3_bucket.function.bucket
    }

    environment_variable {
      name  = "service_name"
      value = var.service_name
    }
  }

  source {
    type      = "CODEPIPELINE"
    buildspec = <<-EOF
    {
      "version": "0.2",
      "phases": {
        "install": {
          "runtime-versions": {
            ${jsonencode(local.buildspec_runtime[var.lambda_runtime])}
          },
          "commands": [
            "pip3 install --upgrade --user awscli",
            "echo 'f6bd1536a743ab170b35c94ed4c7c4479763356bd543af5d391122f4af852460  yq_linux_amd64' > yq_linux_amd64.sha",
            "wget https://github.com/mikefarah/yq/releases/download/3.4.0/yq_linux_amd64",
            "sha256sum -c yq_linux_amd64.sha",
            "mv yq_linux_amd64 /usr/bin/yq",
            "chmod +x /usr/bin/yq"
          ]
        },
        "pre_build": {
          "commands": [
            "cd $CODEBUILD_SRC_DIR/${var.pipeline_code_directory}",
            "${var.pipeline_unit_test_command}"
          ]
        },
        "build": {
          "commands": [
            "${var.pipeline_packaging_command}",
            "FUNCTION_KEY=$CODEBUILD_BUILD_NUMBER/function.zip",
            "aws s3 cp function.zip s3://$bucket_name/$FUNCTION_KEY"
          ]
        },
        "post_build": {
          "commands": [
            "aws proton --region $AWS_DEFAULT_REGION get-service --name $service_name | jq -r .service.spec > service.yaml",
            "yq w service.yaml 'instances[*].spec.lambda_bucket' \"$bucket_name\" > rendered_service.yaml",
            "yq w service.yaml 'instances[*].spec.lambda_key' \"$FUNCTION_KEY\" > rendered_service.yaml"
          ]
        }
      },
      "artifacts": {
        "files": [
          "${var.pipeline_code_directory}/rendered_service.yaml"
        ]
      }
    }
    EOF
  }
}

################################################################################
# IAM Role - Deploy
################################################################################

resource "aws_iam_role" "deploy" {
  name_prefix = "deployment-role"

  assume_role_policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Principal" : {
          "Service" : "codebuild.amazonaws.com"
        },
        "Action" : "sts:AssumeRole"
      }
    ]
  })
}

data "aws_iam_policy_document" "deploy" {
  statement {
    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]

    resources = [
      "arn:aws:logs:${local.region}:${local.account_id}:log-group:/aws/codebuild/Deploy*Project*",
      "arn:aws:logs:${local.region}:${local.account_id}:log-group:/aws/codebuild/Deploy*Project:*",
    ]
  }

  statement {
    actions = [
      "codebuild:CreateReportGroup",
      "codebuild:CreateReport",
      "codebuild:UpdateReport",
      "codebuild:BatchPutTestCases"
    ]

    resources = [
      "arn:aws:codebuild:${local.region}:${local.account_id}:report-group:/Deploy*Project-*",
    ]
  }

  statement {
    actions = [
      "proton:GetServiceInstance",
      "proton:UpdateServiceInstance"
    ]

    resources = ["*"]
  }

  statement {
    actions = [
      "s3:GetObject*",
      "s3:GetBucket*",
      "s3:List*"
    ]

    resources = [
      aws_s3_bucket.pipeline_artifacts.arn,
      "${aws_s3_bucket.pipeline_artifacts.arn}/*"
    ]
  }

  statement {
    actions = [
      "kms:Decrypt",
      "kms:DescribeKey",
      "kms:Encrypt",
      "kms:ReEncrypt*",
      "kms:GenerateDataKey*"
    ]

    resources = [aws_kms_key.pipeline_artifacts.arn]
  }
}

resource "aws_iam_policy" "deploy" {
  policy = data.aws_iam_policy_document.deploy.json
}

resource "aws_iam_role_policy_attachment" "deploy" {
  policy_arn = aws_iam_policy.deploy.arn
  role       = aws_iam_role.deploy.name
}

################################################################################
# CodeBuild Project - Deploy
################################################################################

resource "aws_codebuild_project" "deploy" {
  for_each = var.codebuild_deployments

  name         = "Deploy${try(each.value.name, each.key)}Project"
  service_role = aws_iam_role.deploy.arn

  artifacts {
    type = "CODEPIPELINE"
  }

  environment {
    compute_type                = "BUILD_GENERAL1_SMALL"
    image                       = "aws/codebuild/amazonlinux2-x86_64-standard:3.0"
    type                        = "LINUX_CONTAINER"
    privileged_mode             = false
    image_pull_credentials_type = "CODEBUILD"

    environment_variable {
      name  = "service_instance_name"
      value = try(each.value.name, each.key)
    }

    environment_variable {
      name  = "service_name"
      value = var.service_name
    }
  }

  source {
    type      = "CODEPIPELINE"
    buildspec = <<-EOF
    {
      "version": "0.2",
      "phases": {
        "build": {
          "commands": [
            "pip3 install --upgrade --user awscli",
            "aws proton --region $AWS_DEFAULT_REGION update-service-instance --deployment-type CURRENT_VERSION --name $service_instance_name --service-name $service_name --spec file://${var.pipeline_code_directory}/rendered_service.yaml",
            "aws proton --region $AWS_DEFAULT_REGION wait service-instance-deployed --name $service_instance_name --service-name $service_name"
          ]
        }
      }
    }
    EOF
  }

  encryption_key = aws_kms_key.pipeline_artifacts.arn
}

################################################################################
# IAM Role - CodePipeline
################################################################################

resource "aws_iam_role" "pipeline" {
  name_prefix = "pipeline-role"

  assume_role_policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Principal" : {
          "Service" : "codepipeline.amazonaws.com"
        },
        "Action" : "sts:AssumeRole"
      }
    ]
  })
}

data "aws_iam_policy_document" "pipeline" {
  statement {
    actions = [
      "s3:GetObject*",
      "s3:GetBucket*",
      "s3:List*",
      "s3:DeleteObject*",
      "s3:PutObject*",
      "s3:Abort*"
    ]

    resources = [
      aws_s3_bucket.pipeline_artifacts.arn,
      "${aws_s3_bucket.pipeline_artifacts.arn}*"
    ]
  }

  statement {
    actions = [
      "kms:Decrypt",
      "kms:DescribeKey",
      "kms:Encrypt",
      "kms:ReEncrypt*",
      "kms:GenerateDataKey*"
    ]

    resources = [aws_kms_key.pipeline_artifacts.arn]
  }

  statement {
    actions   = ["codestar-connections:*"]
    resources = ["*"]
  }

  statement {
    actions = ["sts:AssumeRole"]
    resources = [
      aws_iam_role.build.arn,
      aws_iam_role.deploy.arn
    ]
  }
}

resource "aws_iam_policy" "pipeline" {
  policy = data.aws_iam_policy_document.pipeline.json
}

resource "aws_iam_role_policy_attachment" "pipeline" {
  policy_arn = aws_iam_policy.pipeline.arn
  role       = aws_iam_role.pipeline.name
}

################################################################################
# IAM Role - CodePipeline Action
################################################################################

resource "aws_iam_role" "pipeline_action" {
  name_prefix = "pipeline-deploy-action-role"

  assume_role_policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Principal" : {
          "AWS" : "arn:aws:iam::${local.account_id}:root"
        },
        "Action" : "sts:AssumeRole"
      }
    ]
  })
}

data "aws_iam_policy_document" "pipeline_action" {
  statement {
    actions = [
      "codebuild:BatchGetBuilds",
      "codebuild:StartBuild",
      "codebuild:StopBuild"
    ]

    resources = ["arn:aws:codebuild:${local.region}:${local.account_id}:project/Deploy*"]
  }
}

resource "aws_iam_policy" "pipeline_action" {
  policy = data.aws_iam_policy_document.pipeline_action.json
}

resource "aws_iam_role_policy_attachment" "pipeline_action" {
  policy_arn = aws_iam_policy.pipeline_action.arn
  role       = aws_iam_role.pipeline_action.name
}

################################################################################
# CodePipeline
################################################################################

resource "aws_codepipeline" "pipeline" {
  name     = "${var.service_name}-pipeline"
  role_arn = aws_iam_role.pipeline.arn

  stage {
    name = "Source"

    action {
      category  = "Source"
      name      = "Checkout"
      owner     = "AWS"
      provider  = "CodeStarSourceConnection"
      version   = "1"
      run_order = 1

      configuration = {
        ConnectionArn : var.repository_connection_arn
        FullRepositoryId : var.repository_id
        BranchName : var.repository_branch_name
      }

      output_artifacts = ["Artifact_Source_Checkout"]
    }
  }

  stage {
    name = "Build"

    action {
      category  = "Build"
      name      = "Build"
      owner     = "AWS"
      provider  = "CodeBuild"
      version   = "1"
      run_order = 1

      configuration = {
        ProjectName = aws_codebuild_project.build.name
      }

      input_artifacts  = ["Artifact_Source_Checkout"]
      output_artifacts = ["BuildOutput"]
      role_arn         = aws_iam_role.pipeline_action.arn
    }
  }

  dynamic "stage" {
    for_each = var.codebuild_deployments

    content {
      name = "Deploy${try(each.value.name, each.key)}Project"

      action {
        category  = "Build"
        name      = "Deploy${try(each.value.name, each.key)}"
        owner     = "AWS"
        provider  = "CodeBuild"
        version   = "1"
        run_order = 1

        configuration = {
          ProjectName = "Deploy${try(each.value.name, each.key)}Project"
        }

        input_artifacts = ["BuildOutput"]
        role_arn        = aws_iam_role.pipeline_action.arn
      }
    }
  }

  artifact_store {
    encryption_key {
      id   = aws_kms_key.pipeline_artifacts.arn
      type = "KMS"
    }

    location = aws_s3_bucket.pipeline_artifacts.bucket
    type     = "S3"
  }
}
