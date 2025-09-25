# EC2 Module Variables
# Owner: Asma Mahdi

variable "environment" {
  description = "Environment name (dev, staging, prod)"
  type        = string
}

variable "aws_region" {
  description = "AWS region"
  type        = string
}

variable "vpc_id" {
  description = "ID of the VPC"
  type        = string
}

variable "vpc_cidr" {
  description = "CIDR block of the VPC"
  type        = string
}

variable "private_subnet_ids" {
  description = "IDs of the private subnets"
  type        = list(string)
}

variable "target_group_arn" {
  description = "ARN of the target group"
  type        = string
}

variable "alb_security_group_id" {
  description = "ID of the ALB security group"
  type        = string
}

# EC2 Configuration
variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.micro"
}

variable "key_pair_public_key" {
  description = "Public key for EC2 instances (optional)"
  type        = string
  default     = null
}

# Auto Scaling Configuration
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

variable "health_check_grace_period" {
  description = "Health check grace period in seconds"
  type        = number
  default     = 300
}

# Instance Refresh Configuration
variable "enable_instance_refresh" {
  description = "Enable instance refresh"
  type        = bool
  default     = true
}

variable "instance_refresh_strategy" {
  description = "Instance refresh strategy"
  type        = string
  default     = "Rolling"
}

variable "instance_refresh_min_healthy_percentage" {
  description = "Minimum healthy percentage for instance refresh"
  type        = number
  default     = 50
}

# Auto Scaling Policies
variable "scale_up_adjustment" {
  description = "Scale up adjustment"
  type        = number
  default     = 1
}

variable "scale_up_cooldown" {
  description = "Scale up cooldown in seconds"
  type        = number
  default     = 300
}

variable "scale_down_adjustment" {
  description = "Scale down adjustment"
  type        = number
  default     = -1
}

variable "scale_down_cooldown" {
  description = "Scale down cooldown in seconds"
  type        = number
  default     = 300
}

# Security Configuration
variable "your_ip" {
  description = "Your public IP in CIDR (/32) for SSH"
  type        = string
  default     = null
}

variable "bastion_security_group_id" {
  description = "ID of the bastion security group (optional)"
  type        = string
  default     = null
}

# Database Configuration
variable "db_endpoint" {
  description = "Database endpoint"
  type        = string
  default     = ""
}

variable "db_name" {
  description = "Database name"
  type        = string
  default     = ""
}

variable "db_username" {
  description = "Database username"
  type        = string
  default     = ""
}

variable "db_password" {
  description = "Database password"
  type        = string
  default     = ""
  sensitive   = true
}

# S3 Configuration
variable "s3_bucket_name" {
  description = "S3 bucket name"
  type        = string
  default     = ""
}

variable "s3_bucket_arns" {
  description = "S3 bucket ARNs for IAM policy"
  type        = list(string)
  default     = []
}
