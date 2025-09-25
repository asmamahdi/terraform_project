# S3 Module Variables
# Owner: Asma Mahdi

variable "environment" {
  description = "Environment name (dev, staging, prod)"
  type        = string
}

variable "assets_bucket_name" {
  description = "S3 bucket name for app assets"
  type        = string
}

variable "logs_bucket_name" {
  description = "S3 bucket name for logs"
  type        = string
}

# Assets Bucket Configuration
variable "enable_assets_versioning" {
  description = "Enable versioning for assets bucket"
  type        = bool
  default     = true
}

variable "assets_transition_to_ia_days" {
  description = "Days before transitioning assets to IA storage"
  type        = number
  default     = 30
}

variable "assets_transition_to_glacier_days" {
  description = "Days before transitioning assets to Glacier storage"
  type        = number
  default     = 90
}

variable "assets_noncurrent_version_expiration_days" {
  description = "Days before expiring non-current versions of assets"
  type        = number
  default     = 365
}

# Logs Bucket Configuration
variable "enable_logs_versioning" {
  description = "Enable versioning for logs bucket"
  type        = bool
  default     = false
}

variable "logs_expiration_days" {
  description = "Days before expiring logs"
  type        = number
  default     = 30
}

variable "logs_noncurrent_version_expiration_days" {
  description = "Days before expiring non-current versions of logs"
  type        = number
  default     = 7
}

# ALB Logs Configuration
variable "enable_alb_logs" {
  description = "Enable ALB access logs to S3"
  type        = bool
  default     = false
}
