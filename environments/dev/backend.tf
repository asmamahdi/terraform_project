# Dev Environment - Backend Configuration
# This file configures the S3 backend for remote state management

terraform {
  backend "s3" {
    # These values will be provided during terraform init
    # bucket         = "your-terraform-state-bucket"
    # key            = "dev/terraform.tfstate"
    # region         = "us-east-1"
    # dynamodb_table = "terraform-state-locks"
    # encrypt        = true
  }
}