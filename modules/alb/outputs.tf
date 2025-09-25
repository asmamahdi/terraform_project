# ALB Module Outputs
# Owner: Asma Mahdi

output "alb_id" {
  description = "ID of the Application Load Balancer"
  value       = aws_lb.main.id
}

output "alb_arn" {
  description = "ARN of the Application Load Balancer"
  value       = aws_lb.main.arn
}

output "alb_dns_name" {
  description = "DNS name of the Application Load Balancer"
  value       = aws_lb.main.dns_name
}

output "alb_zone_id" {
  description = "Zone ID of the Application Load Balancer"
  value       = aws_lb.main.zone_id
}

output "target_group_id" {
  description = "ID of the Target Group"
  value       = aws_lb_target_group.main.id
}

output "target_group_arn" {
  description = "ARN of the Target Group"
  value       = aws_lb_target_group.main.arn
}

output "alb_security_group_id" {
  description = "ID of the ALB Security Group"
  value       = aws_security_group.alb.id
}

output "website_url" {
  description = "URL of the website"
  value       = "http://${aws_lb.main.dns_name}"
}

output "website_url_https" {
  description = "HTTPS URL of the website (if SSL enabled)"
  value       = var.enable_ssl ? "https://${aws_lb.main.dns_name}" : null
}
