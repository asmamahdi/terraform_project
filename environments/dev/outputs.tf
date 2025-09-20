# Dev Environment - Output Values
# This file contains output values that can be used by other configurations

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

output "private_subnet_ids" {
  description = "IDs of the private subnets"
  value       = module.vpc.private_subnet_ids
}

# Note: Individual EC2 instance IDs/IPs are not available with Auto Scaling Groups
# Use AWS CLI or console to view current instances in the ASG

output "rds_endpoint" {
  description = "RDS instance endpoint"
  value       = module.rds.endpoint
}

output "rds_port" {
  description = "RDS instance port"
  value       = module.rds.port
}

# ALB outputs
output "alb_dns_name" {
  description = "DNS name of the Application Load Balancer"
  value       = module.alb.alb_dns_name
}

output "alb_zone_id" {
  description = "Zone ID of the Application Load Balancer"
  value       = module.alb.alb_zone_id
}

output "target_group_arn" {
  description = "ARN of the target group"
  value       = module.alb.target_group_arn
}

# Auto Scaling Group outputs
output "asg_name" {
  description = "Name of the Auto Scaling Group"
  value       = module.ec2.asg_name
}

output "asg_arn" {
  description = "ARN of the Auto Scaling Group"
  value       = module.ec2.asg_arn
}

# Ansible inventory information
output "ansible_inventory" {
  description = "Information for Ansible inventory"
  value = {
    environment = "dev"
    app_name    = var.app_name
    app_port    = 8080
    alb_dns     = module.alb.alb_dns_name
  }
}