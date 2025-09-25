# EC2 Module Outputs
# Owner: Asma Mahdi

output "asg_id" {
  description = "ID of the Auto Scaling Group"
  value       = aws_autoscaling_group.main.id
}

output "asg_arn" {
  description = "ARN of the Auto Scaling Group"
  value       = aws_autoscaling_group.main.arn
}

output "asg_name" {
  description = "Name of the Auto Scaling Group"
  value       = aws_autoscaling_group.main.name
}

output "launch_template_id" {
  description = "ID of the Launch Template"
  value       = aws_launch_template.main.id
}

output "launch_template_arn" {
  description = "ARN of the Launch Template"
  value       = aws_launch_template.main.arn
}

output "ec2_security_group_id" {
  description = "ID of the EC2 Security Group"
  value       = aws_security_group.ec2.id
}

output "iam_role_arn" {
  description = "ARN of the EC2 IAM Role"
  value       = aws_iam_role.ec2_role.arn
}

output "iam_instance_profile_arn" {
  description = "ARN of the EC2 IAM Instance Profile"
  value       = aws_iam_instance_profile.ec2_profile.arn
}

output "key_pair_name" {
  description = "Name of the Key Pair (if created)"
  value       = var.key_pair_public_key != null ? aws_key_pair.main[0].key_name : null
}
