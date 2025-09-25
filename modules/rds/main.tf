# RDS Module - Relational Database Service
# Owner: Asma Mahdi
# Purpose: Reusable RDS MySQL database

# DB Subnet Group
resource "aws_db_subnet_group" "main" {
  name       = "${var.environment}-db-subnet-group"
  subnet_ids = var.private_db_subnet_ids

  tags = {
    Name        = "${var.environment}-db-subnet-group"
    Environment = var.environment
    ManagedBy   = "terraform"
  }
}

# RDS Instance
resource "aws_db_instance" "main" {
  identifier = "${var.environment}-rds"

  # Engine Configuration
  engine         = var.db_engine
  engine_version = var.db_engine_version
  instance_class = var.db_instance_class

  # Storage Configuration
  allocated_storage     = var.db_allocated_storage
  max_allocated_storage = var.db_max_allocated_storage
  storage_type          = var.db_storage_type
  storage_encrypted     = var.db_storage_encrypted

  # Database Configuration
  db_name  = var.db_name
  username = var.db_username
  password = var.db_password

  # Network Configuration
  db_subnet_group_name   = aws_db_subnet_group.main.name
  vpc_security_group_ids = [aws_security_group.rds.id]
  publicly_accessible    = false

  # Backup Configuration
  backup_retention_period = var.backup_retention_period
  backup_window          = var.backup_window
  maintenance_window     = var.maintenance_window

  # Monitoring Configuration
  monitoring_interval = var.monitoring_interval
  monitoring_role_arn = var.monitoring_interval > 0 ? aws_iam_role.rds_enhanced_monitoring[0].arn : null

  # Performance Insights
  performance_insights_enabled          = var.performance_insights_enabled
  performance_insights_retention_period = var.performance_insights_enabled ? var.performance_insights_retention_period : null

  # Deletion Protection
  deletion_protection = var.deletion_protection
  skip_final_snapshot = var.skip_final_snapshot
  final_snapshot_identifier = var.skip_final_snapshot ? null : "${var.environment}-rds-final-snapshot-${formatdate("YYYY-MM-DD-hhmm", timestamp())}"

  # Multi-AZ Configuration
  multi_az = var.multi_az

  tags = {
    Name        = "${var.environment}-rds"
    Environment = var.environment
    ManagedBy   = "terraform"
  }
}

# Security Group for RDS
resource "aws_security_group" "rds" {
  name_prefix = "${var.environment}-rds-sg"
  description = "Security group for RDS database"
  vpc_id      = var.vpc_id

  # MySQL/Aurora from EC2 instances
  ingress {
    description     = "Database traffic from EC2 instances"
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [var.ec2_security_group_id]
  }

  # MySQL/Aurora from Bastion (conditional)
  dynamic "ingress" {
    for_each = var.bastion_security_group_id != null ? [1] : []
    content {
      description     = "Database traffic from bastion host"
      from_port       = 3306
      to_port         = 3306
      protocol        = "tcp"
      security_groups = [var.bastion_security_group_id]
    }
  }

  # Temporary: Allow all VPC traffic for debugging (remove in production)
  dynamic "ingress" {
    for_each = var.enable_vpc_debug_rule ? [1] : []
    content {
      description = "Database traffic from VPC (temporary debug rule)"
      from_port   = 3306
      to_port     = 3306
      protocol    = "tcp"
      cidr_blocks = [var.vpc_cidr]
    }
  }

  tags = {
    Name        = "${var.environment}-rds-sg"
    Environment = var.environment
    ManagedBy   = "terraform"
  }
}

# IAM Role for Enhanced Monitoring (optional)
resource "aws_iam_role" "rds_enhanced_monitoring" {
  count = var.monitoring_interval > 0 ? 1 : 0
  
  name = "${var.environment}-rds-monitoring-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "monitoring.rds.amazonaws.com"
        }
      }
    ]
  })

  tags = {
    Name        = "${var.environment}-rds-monitoring-role"
    Environment = var.environment
    ManagedBy   = "terraform"
  }
}

# Attach the AWS managed policy for RDS Enhanced Monitoring
resource "aws_iam_role_policy_attachment" "rds_enhanced_monitoring" {
  count = var.monitoring_interval > 0 ? 1 : 0
  
  role       = aws_iam_role.rds_enhanced_monitoring[0].name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonRDSEnhancedMonitoringRole"
}
