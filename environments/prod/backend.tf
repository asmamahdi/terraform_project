# S3 Backend Configuration for Production Environment
# Owner: Asma Mahdi

terraform {
  backend "s3" {
    bucket         = "terraform-state-asma-practice-20250924233440"
    key            = "environments/prod/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "terraform-state-locks"
    encrypt        = true
  }
}
