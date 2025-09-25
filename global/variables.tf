# Global Variables
# Owner: Asma Mahdi
# Purpose: Shared variables used across all environments

# General Variables
variable "aws_region" {
  description = "AWS region for resources"
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "Project name"
  type        = string
  default     = "AWS Practice Environment"
}

variable "owner" {
  description = "Owner of the resources"
  type        = string
  default     = "Asma Mahdi"
}

variable "environment" {
  description = "Environment name (dev, staging, prod)"
  type        = string
}
