# RDS Module - Main Configuration
# This module creates RDS instances with security groups

# Create Security Group for RDS
resource "aws_security_group" "rds" {
  name_prefix = "${var.environment}-rds-sg"
  vpc_id      = var.vpc_id
  
  # MySQL/Aurora access
  ingress {
    from_port       = var.db_port
    to_port         = var.db_port
    protocol        = "tcp"
    security_groups = var.allowed_security_group_ids
  }
  
  # PostgreSQL access
  ingress {
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = var.allowed_security_group_ids
  }
  
  tags = {
    Name        = "${var.environment}-rds-sg"
    Environment = var.environment
    ManagedBy   = "terraform"
  }
}

# Create random suffix for unique naming
resource "random_id" "db_subnet_group_suffix" {
  byte_length = 4
}

# Create RDS Subnet Group
resource "aws_db_subnet_group" "main" {
  name       = "${var.environment}-rds-subnet-group-${random_id.db_subnet_group_suffix.hex}"
  subnet_ids = var.subnet_ids
  
  tags = {
    Name        = "${var.environment}-rds-subnet-group"
    Environment = var.environment
    ManagedBy   = "terraform"
  }
}

# Create RDS Instance
resource "aws_db_instance" "main" {
  identifier = "${var.environment}-rds"
  
  engine               = var.engine
  engine_version       = var.engine_version
  instance_class       = var.instance_class
  allocated_storage    = var.allocated_storage
  storage_type         = var.storage_type
  
  db_name  = var.db_name
  username = var.db_username
  password = var.db_password
  
  vpc_security_group_ids = [aws_security_group.rds.id]
  db_subnet_group_name   = aws_db_subnet_group.main.name
  
  backup_retention_period = var.backup_retention_period
  backup_window          = var.backup_window
  maintenance_window     = var.maintenance_window
  
  skip_final_snapshot = var.skip_final_snapshot
  
  tags = {
    Name        = "${var.environment}-rds"
    Environment = var.environment
    ManagedBy   = "terraform"
  }
}
