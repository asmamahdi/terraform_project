# Backend Environment - Output Values
# This file contains output values for the S3 backend infrastructure

output "s3_bucket_name" {
  description = "Name of the S3 bucket for Terraform state"
  value       = module.s3_backend.s3_bucket_name
}

output "s3_bucket_arn" {
  description = "ARN of the S3 bucket for Terraform state"
  value       = module.s3_backend.s3_bucket_arn
}

output "dynamodb_table_name" {
  description = "Name of the DynamoDB table for state locking"
  value       = module.s3_backend.dynamodb_table_name
}

output "dynamodb_table_arn" {
  description = "ARN of the DynamoDB table for state locking"
  value       = module.s3_backend.dynamodb_table_arn
}

output "backend_config" {
  description = "Backend configuration for other environments"
  value       = module.s3_backend.backend_config
}

# Removed IAM user outputs to keep this Terraform-only
