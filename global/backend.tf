# Global Backend Configuration
# Owner: Asma Mahdi
# Purpose: Shared backend configuration for all environments

# S3 Backend Configuration
# Note: This is a template. Each environment should have its own backend configuration
# Example backend configuration for environments:
#
# terraform {
#   backend "s3" {
#     bucket         = "your-terraform-state-bucket"
#     key            = "environments/dev/terraform.tfstate"
#     region         = "us-east-1"
#     dynamodb_table = "terraform-state-locks"
#     encrypt        = true
#   }
# }
