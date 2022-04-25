output "pipeline_endpoint" {
  description = "CodePipeline endpoint URL"
  value       = "https://${local.region}.console.aws.amazon.com/codesuite/codepipeline/pipelines/${aws_codepipeline.pipeline.id}/view?region=${local.region}"
}
