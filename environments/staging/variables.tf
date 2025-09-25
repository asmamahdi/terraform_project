# Staging Environment Variables
# Owner: Asma Mahdi

# General Variables
variable "environment" {
  description = "Environment name"
  type        = string
  default     = "staging"
}

variable "aws_region" {
  description = "AWS region for resources"
  type        = string
  default     = "us-east-1"
}

# VPC Variables
variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
  default     = "10.1.0.0/16"
}

variable "public_subnet_cidrs" {
  description = "CIDRs for public subnets"
  type        = list(string)
  default     = ["10.1.0.0/24", "10.1.1.0/24"]
}

variable "private_app_subnet_cidrs" {
  description = "CIDRs for private app subnets"
  type        = list(string)
  default     = ["10.1.10.0/24", "10.1.11.0/24"]
}

variable "private_db_subnet_cidrs" {
  description = "CIDRs for private DB subnets"
  type        = list(string)
  default     = ["10.1.20.0/24", "10.1.21.0/24"]
}

# Security Variables
variable "your_ip" {
  description = "Your public IP in CIDR (/32) for SSH"
  type        = string
  default     = null
}

# EC2 Variables
variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.micro"
}

variable "min_size" {
  description = "Minimum number of EC2 instances in ASG"
  type        = number
  default     = 1
}

variable "max_size" {
  description = "Maximum number of EC2 instances in ASG"
  type        = number
  default     = 3
}

variable "desired_capacity" {
  description = "Desired number of EC2 instances in ASG"
  type        = number
  default     = 2
}

# RDS Variables
variable "db_name" {
  description = "Database name"
  type        = string
  default     = "practicedb"
}

variable "db_username" {
  description = "Database username"
  type        = string
  default     = "admin"
}

variable "db_password" {
  description = "Database password"
  type        = string
  sensitive   = true
}

variable "db_instance_class" {
  description = "RDS instance class"
  type        = string
  default     = "db.t3.micro"
}

variable "db_allocated_storage" {
  description = "RDS allocated storage in GB"
  type        = number
  default     = 20
}

variable "backup_retention_period" {
  description = "RDS backup retention period in days"
  type        = number
  default     = 7
}

variable "rds_multi_az" {
  description = "Enable Multi-AZ for RDS"
  type        = bool
  default     = true
}

variable "rds_deletion_protection" {
  description = "Enable deletion protection for RDS"
  type        = bool
  default     = true
}

# S3 Variables
variable "assets_bucket_name" {
  description = "S3 bucket name for app assets"
  type        = string
  default     = "staging-app-assets-asma-practice"
}

variable "logs_bucket_name" {
  description = "S3 bucket name for logs"
  type        = string
  default     = "staging-app-logs-asma-practice"
}
