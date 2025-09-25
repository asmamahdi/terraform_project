# RDS Module Outputs
# Owner: Asma Mahdi

output "db_instance_id" {
  description = "ID of the RDS instance"
  value       = aws_db_instance.main.id
}

output "db_instance_arn" {
  description = "ARN of the RDS instance"
  value       = aws_db_instance.main.arn
}

output "db_endpoint" {
  description = "RDS instance endpoint"
  value       = aws_db_instance.main.endpoint
}

output "db_port" {
  description = "RDS instance port"
  value       = aws_db_instance.main.port
}

output "db_name" {
  description = "Database name"
  value       = aws_db_instance.main.db_name
}

output "db_username" {
  description = "Database username"
  value       = aws_db_instance.main.username
}

output "db_engine" {
  description = "Database engine"
  value       = aws_db_instance.main.engine
}

output "db_engine_version" {
  description = "Database engine version"
  value       = aws_db_instance.main.engine_version
}

output "db_instance_class" {
  description = "Database instance class"
  value       = aws_db_instance.main.instance_class
}

output "db_multi_az" {
  description = "Multi-AZ deployment status"
  value       = aws_db_instance.main.multi_az
}

output "db_backup_retention_period" {
  description = "Backup retention period"
  value       = aws_db_instance.main.backup_retention_period
}

output "db_security_group_id" {
  description = "ID of the RDS security group"
  value       = aws_security_group.rds.id
}

output "db_subnet_group_id" {
  description = "ID of the DB subnet group"
  value       = aws_db_subnet_group.main.id
}

output "db_subnet_group_arn" {
  description = "ARN of the DB subnet group"
  value       = aws_db_subnet_group.main.arn
}

output "db_connection_string" {
  description = "Database connection string"
  value       = "${aws_db_instance.main.endpoint}:${aws_db_instance.main.port}"
}
