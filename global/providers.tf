# Global Provider Configuration
# This file contains the AWS provider configuration

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
  
  required_version = ">= 1.0"
}

# Configure the AWS Provider
provider "aws" {
  region = "us-east-1"
  
  default_tags {
    tags = {
      Project     = "terraform-project"
      ManagedBy   = "terraform"
      Environment = "global"
    }
  }
}
