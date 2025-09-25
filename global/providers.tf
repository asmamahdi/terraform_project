# Global Provider Configuration
# Owner: Asma Mahdi
# Purpose: Shared provider configurations for all environments

terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.1"
    }
  }
}

# AWS Provider Configuration
provider "aws" {
  region = var.aws_region
  
  default_tags {
    tags = {
      Project     = var.project_name
      Owner       = var.owner
      ManagedBy   = "Terraform"
      Environment = var.environment
    }
  }
}
