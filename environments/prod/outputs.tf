# Staging Environment - Outputs
# This file defines the output values for the staging environment

output "vpc_id" {
  description = "The ID of the VPC"
  value       = module.vpc.vpc_id
}

output "vpc_cidr_block" {
  description = "The CIDR block of the VPC"
  value       = module.vpc.vpc_cidr_block
}

output "public_subnet_ids" {
  description = "List of IDs of public subnets"
  value       = module.vpc.public_subnet_ids
}

output "private_subnet_ids" {
  description = "List of IDs of private subnets"
  value       = module.vpc.private_subnet_ids
}

# Note: Individual EC2 instance IDs/IPs are not available with Auto Scaling Groups
# Use AWS CLI or console to view current instances in the ASG

output "rds_endpoint" {
  description = "The connection endpoint for the RDS instance"
  value       = module.rds.endpoint
}

output "rds_port" {
  description = "The port on which the RDS instance accepts connections"
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
