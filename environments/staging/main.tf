# Staging Environment - Main Configuration
# This file contains the primary resource definitions for the staging environment

terraform {
  required_version = ">= 1.0"
}

# Configure the AWS Provider
provider "aws" {
  region = var.aws_region
  
  default_tags {
    tags = {
      Environment = "staging"
      Project     = var.project_name
      ManagedBy   = "terraform"
    }
  }
}

# VPC Module
module "vpc" {
  source = "../../modules/vpc"
  
  vpc_cidr             = var.vpc_cidr
  environment          = "staging"
  availability_zones   = var.availability_zones
  public_subnet_cidrs  = var.public_subnet_cidrs
  private_subnet_cidrs = var.private_subnet_cidrs
}

# ALB Module
module "alb" {
  source = "../../modules/alb"
  
  vpc_id              = module.vpc.vpc_id
  public_subnet_ids   = module.vpc.public_subnet_ids
  environment         = "staging"
  target_port         = 8080
  health_check_path   = "/health.html"
  certificate_arn     = var.certificate_arn
  enable_deletion_protection = false
}

# EC2 Module
module "ec2" {
  source = "../../modules/ec2"
  
  vpc_id             = module.vpc.vpc_id
  subnet_ids         = module.vpc.private_subnet_ids
  environment        = "staging"
  instance_type      = var.ec2_instance_type
  key_name           = var.ec2_key_name
  ami_id             = var.ec2_ami_id
  min_size           = var.ec2_min_size
  max_size           = var.ec2_max_size
  desired_capacity   = var.ec2_desired_capacity
  target_group_arns  = [module.alb.target_group_arn]
  allowed_ssh_cidrs  = var.allowed_ssh_cidrs
  application_ports  = var.application_ports
  app_name           = var.app_name
}

# RDS Module
module "rds" {
  source = "../../modules/rds"
  
  vpc_id           = module.vpc.vpc_id
  subnet_ids       = module.vpc.private_subnet_ids
  environment      = "staging"
  instance_class   = var.rds_instance_class
  allocated_storage = var.rds_allocated_storage
  engine           = var.rds_engine
  engine_version   = var.rds_engine_version
  db_name          = var.rds_db_name
  db_username      = var.rds_username
  db_password      = var.rds_password
  db_port          = var.rds_port
  skip_final_snapshot = var.rds_skip_final_snapshot
}
