# Backend Environment - S3 Backend Infrastructure
# This environment creates the S3 bucket and DynamoDB table for Terraform state management

terraform {
  required_version = ">= 1.0"
  
  # This environment uses local state (bootstrap)
  # Once created, other environments will use this S3 backend
}

# Configure the AWS Provider
provider "aws" {
  region = var.aws_region
  
  default_tags {
    tags = {
      Environment = "backend"
      Project     = var.project_name
      ManagedBy   = "terraform"
    }
  }
}

# S3 Backend Module
module "s3_backend" {
  source = "../../modules/s3-backend"
  
  bucket_name           = var.bucket_name
  dynamodb_table_name   = var.dynamodb_table_name
  environment          = "backend"
  # Removed create_terraform_user to keep this Terraform-only
  region               = var.aws_region
}
