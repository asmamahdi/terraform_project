# RDS Module - Output Values
# This file contains output values that can be used by other modules

output "endpoint" {
  description = "RDS instance endpoint"
  value       = aws_db_instance.main.endpoint
}

output "port" {
  description = "RDS instance port"
  value       = aws_db_instance.main.port
}

output "identifier" {
  description = "RDS instance identifier"
  value       = aws_db_instance.main.identifier
}

output "engine" {
  description = "RDS engine type"
  value       = aws_db_instance.main.engine
}

output "engine_version" {
  description = "RDS engine version"
  value       = aws_db_instance.main.engine_version
}

output "instance_class" {
  description = "RDS instance class"
  value       = aws_db_instance.main.instance_class
}

output "allocated_storage" {
  description = "RDS allocated storage"
  value       = aws_db_instance.main.allocated_storage
}
