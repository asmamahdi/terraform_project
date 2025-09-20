# Dev Environment - Main Configuration
# This file contains the primary resource definitions for the development environment

terraform {
  required_version = ">= 1.0"
}

# Configure the AWS Provider
provider "aws" {
  region = var.aws_region
  
  default_tags {
    tags = {
      Environment = "dev"
      Project     = var.project_name
      ManagedBy   = "terraform"
    }
  }
}

# VPC Module
module "vpc" {
  source = "../../modules/vpc"
  
  vpc_cidr             = var.vpc_cidr
  environment          = "dev"
  availability_zones   = var.availability_zones
  public_subnet_cidrs  = var.public_subnet_cidrs
  private_subnet_cidrs = var.private_subnet_cidrs
}

# EC2 Module
module "ec2" {
  source = "../../modules/ec2"
  
  vpc_id           = module.vpc.vpc_id
  subnet_ids       = module.vpc.private_subnet_ids
  environment      = "dev"
  instance_type    = var.ec2_instance_type
  key_name         = var.ec2_key_name
  instance_count   = var.ec2_instance_count
  ami_id           = var.ec2_ami_id
}

# RDS Module
module "rds" {
  source = "../../modules/rds"
  
  vpc_id           = module.vpc.vpc_id
  subnet_ids       = module.vpc.private_subnet_ids
  environment      = "dev"
  instance_class   = var.rds_instance_class
  allocated_storage = var.rds_allocated_storage
  engine           = var.rds_engine
  engine_version   = var.rds_engine_version
  db_name          = var.rds_db_name
  db_username      = var.rds_username
  db_password      = var.rds_password
  db_port          = var.rds_port
}
