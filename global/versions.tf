# Global Version Constraints
# This file contains version constraints for Terraform and providers

terraform {
  required_version = ">= 1.0"
  
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    
    random = {
      source  = "hashicorp/random"
      version = "~> 3.0"
    }
    
    local = {
      source  = "hashicorp/local"
      version = "~> 2.0"
    }
  }
}
