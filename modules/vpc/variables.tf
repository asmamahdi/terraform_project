# VPC Module Variables
# Owner: Asma Mahdi

variable "environment" {
  description = "Environment name (dev, staging, prod)"
  type        = string
}

variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidrs" {
  description = "CIDRs for public subnets"
  type        = list(string)
  default     = ["10.0.0.0/24", "10.0.1.0/24"]
  validation {
    condition     = length(var.public_subnet_cidrs) >= 2
    error_message = "Provide at least two public subnets for HA."
  }
}

variable "private_app_subnet_cidrs" {
  description = "CIDRs for private app subnets"
  type        = list(string)
  default     = ["10.0.10.0/24", "10.0.11.0/24"]
  validation {
    condition     = length(var.private_app_subnet_cidrs) == length(var.public_subnet_cidrs)
    error_message = "private_app_subnet_cidrs must match public_subnet_cidrs count."
  }
}

variable "private_db_subnet_cidrs" {
  description = "CIDRs for private DB subnets"
  type        = list(string)
  default     = ["10.0.20.0/24", "10.0.21.0/24"]
  validation {
    condition     = length(var.private_db_subnet_cidrs) == length(var.public_subnet_cidrs)
    error_message = "private_db_subnet_cidrs must match public_subnet_cidrs count."
  }
}
