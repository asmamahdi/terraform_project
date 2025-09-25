# Dev Environment - Main Configuration
# Owner: Asma Mahdi
# Purpose: Development environment using reusable modules

# VPC Module
module "vpc" {
  source = "../../modules/vpc"
  
  environment                 = var.environment
  vpc_cidr                   = var.vpc_cidr
  public_subnet_cidrs        = var.public_subnet_cidrs
  private_app_subnet_cidrs   = var.private_app_subnet_cidrs
  private_db_subnet_cidrs    = var.private_db_subnet_cidrs
}

# S3 Module
module "s3" {
  source = "../../modules/s3"
  
  environment       = var.environment
  assets_bucket_name = var.assets_bucket_name
  logs_bucket_name  = var.logs_bucket_name
  
  enable_alb_logs = true
}

# ALB Module
module "alb" {
  source = "../../modules/alb"
  
  environment          = var.environment
  vpc_id              = module.vpc.vpc_id
  public_subnet_ids   = module.vpc.public_subnet_ids
  s3_logs_bucket      = module.s3.logs_bucket_id
  
  health_check_path   = "/health"
  health_check_port   = "traffic-port"
  health_check_protocol = "HTTP"
  health_check_matcher = "200"
}

# RDS Module
module "rds" {
  source = "../../modules/rds"
  
  environment                = var.environment
  vpc_id                    = module.vpc.vpc_id
  vpc_cidr                  = module.vpc.vpc_cidr_block
  private_db_subnet_ids     = module.vpc.private_db_subnet_ids
  ec2_security_group_id     = module.ec2.ec2_security_group_id
  
  db_name                   = var.db_name
  db_username               = var.db_username
  db_password               = var.db_password
  db_instance_class         = var.db_instance_class
  db_allocated_storage      = var.db_allocated_storage
  
  backup_retention_period   = var.backup_retention_period
  multi_az                  = var.rds_multi_az
  deletion_protection       = var.rds_deletion_protection
}

# EC2 Module
module "ec2" {
  source = "../../modules/ec2"
  
  environment               = var.environment
  aws_region               = var.aws_region
  vpc_id                   = module.vpc.vpc_id
  vpc_cidr                 = module.vpc.vpc_cidr_block
  private_subnet_ids       = module.vpc.private_app_subnet_ids
  target_group_arn         = module.alb.target_group_arn
  alb_security_group_id    = module.alb.alb_security_group_id
  
  instance_type            = var.instance_type
  min_size                 = var.min_size
  max_size                 = var.max_size
  desired_capacity         = var.desired_capacity
  
  db_endpoint              = module.rds.db_endpoint
  db_name                  = module.rds.db_name
  db_username              = module.rds.db_username
  db_password              = var.db_password
  s3_bucket_name           = module.s3.assets_bucket_name
  s3_bucket_arns           = [module.s3.assets_bucket_arn, module.s3.logs_bucket_arn]
  
  your_ip                  = var.your_ip
}
