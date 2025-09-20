# Backend Environment - Variable Declarations
# This file contains all input variable declarations for the backend environment

variable "aws_region" {
  description = "AWS region for backend resources"
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "Name of the project"
  type        = string
  default     = "terraform-project"
}

variable "bucket_name" {
  description = "Name of the S3 bucket for Terraform state (must be globally unique)"
  type        = string
  default     = "terraform-state-bucket-unique-name-2024"
}

variable "dynamodb_table_name" {
  description = "Name of the DynamoDB table for state locking"
  type        = string
  default     = "terraform-state-locks"
}

# Removed create_terraform_user variable to keep this Terraform-only
