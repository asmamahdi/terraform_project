# Dev Environment Outputs
# Owner: Asma Mahdi

# VPC Outputs
output "vpc_id" {
  description = "ID of the VPC"
  value       = module.vpc.vpc_id
}

output "vpc_cidr_block" {
  description = "CIDR block of the VPC"
  value       = module.vpc.vpc_cidr_block
}

output "public_subnet_ids" {
  description = "IDs of the public subnets"
  value       = module.vpc.public_subnet_ids
}

output "private_app_subnet_ids" {
  description = "IDs of the private app subnets"
  value       = module.vpc.private_app_subnet_ids
}

output "private_db_subnet_ids" {
  description = "IDs of the private DB subnets"
  value       = module.vpc.private_db_subnet_ids
}

# ALB Outputs
output "alb_dns_name" {
  description = "DNS name of the Application Load Balancer"
  value       = module.alb.alb_dns_name
}

output "alb_zone_id" {
  description = "Zone ID of the Application Load Balancer"
  value       = module.alb.alb_zone_id
}

output "website_url" {
  description = "URL of the website"
  value       = module.alb.website_url
}

# EC2 Outputs
output "asg_name" {
  description = "Name of the Auto Scaling Group"
  value       = module.ec2.asg_name
}

output "asg_arn" {
  description = "ARN of the Auto Scaling Group"
  value       = module.ec2.asg_arn
}

# RDS Outputs
output "rds_endpoint" {
  description = "RDS instance endpoint"
  value       = module.rds.db_endpoint
}

output "rds_port" {
  description = "RDS instance port"
  value       = module.rds.db_port
}

output "rds_connection_string" {
  description = "Database connection string"
  value       = module.rds.db_connection_string
}

# S3 Outputs
output "assets_bucket_name" {
  description = "Name of the assets S3 bucket"
  value       = module.s3.assets_bucket_name
}

output "logs_bucket_name" {
  description = "Name of the logs S3 bucket"
  value       = module.s3.logs_bucket_name
}

# Summary Output
output "deployment_summary" {
  description = "Summary of the deployed infrastructure"
  value = {
    environment     = var.environment
    region         = var.aws_region
    vpc_id         = module.vpc.vpc_id
    website_url    = module.alb.website_url
    rds_endpoint   = module.rds.db_endpoint
    asg_name       = module.ec2.asg_name
    assets_bucket  = module.s3.assets_bucket_name
    logs_bucket    = module.s3.logs_bucket_name
  }
}
