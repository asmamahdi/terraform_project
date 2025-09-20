# S3 Backend Module - Variable Declarations
# This file contains all input variable declarations for the S3 backend module

variable "bucket_name" {
  description = "Name of the S3 bucket for Terraform state"
  type        = string
}

variable "dynamodb_table_name" {
  description = "Name of the DynamoDB table for state locking"
  type        = string
}

variable "environment" {
  description = "Environment name (dev, staging, prod)"
  type        = string
}

# Removed create_terraform_user variable to keep this Terraform-only

variable "region" {
  description = "AWS region for the backend resources"
  type        = string
  default     = "us-east-1"
}
