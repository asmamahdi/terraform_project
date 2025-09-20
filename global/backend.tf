# Global Backend Configuration
# This file defines the S3 backend configuration for remote state management
# NOTE: S3 backend has been destroyed - using local state for now

# terraform {
#   backend "s3" {
#     bucket         = "terraform-aws-project-state-713181485982"
#     key            = "global/terraform.tfstate"
#     region         = "us-east-1"
#     dynamodb_table = "terraform-locks"
#     encrypt        = true
#   }
# }

# Note: This backend configuration is commented out since the S3 backend has been destroyed.
# To re-enable S3 backend, you'll need to:
# 1. Create a new S3 bucket
# 2. Create a new DynamoDB table
# 3. Update the bucket name and table name in this file
# 4. Uncomment the backend configuration
