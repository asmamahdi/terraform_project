# S3 Backend Variables
# Owner: Asma Mahdi

variable "aws_region" {
  description = "AWS region for the S3 backend"
  type        = string
  default     = "us-east-1"
}

variable "bucket_name" {
  description = "Name of the S3 bucket for Terraform state"
  type        = string
}
