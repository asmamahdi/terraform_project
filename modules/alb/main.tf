# ALB Module - Application Load Balancer
# Owner: Asma Mahdi
# Purpose: Reusable ALB, Target Groups, Listeners

# Application Load Balancer
resource "aws_lb" "main" {
  name               = "${var.environment}-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb.id]
  subnets            = var.public_subnet_ids

  enable_deletion_protection = var.enable_deletion_protection

  # Access logs to S3 (optional)
  dynamic "access_logs" {
    for_each = var.s3_logs_bucket != null ? [1] : []
    content {
      bucket  = var.s3_logs_bucket
      prefix  = "alb-access-logs"
      enabled = true
    }
  }

  tags = {
    Name        = "${var.environment}-alb"
    Environment = var.environment
    ManagedBy   = "terraform"
  }
}

# Target Group for EC2 instances
resource "aws_lb_target_group" "main" {
  name     = "${var.environment}-tg"
  port     = var.target_group_port
  protocol = var.target_group_protocol
  vpc_id   = var.vpc_id

  # Health check configuration
  health_check {
    enabled             = true
    healthy_threshold   = var.health_check_healthy_threshold
    interval            = var.health_check_interval
    matcher             = var.health_check_matcher
    path                = var.health_check_path
    port                = var.health_check_port
    protocol            = var.health_check_protocol
    timeout             = var.health_check_timeout
    unhealthy_threshold = var.health_check_unhealthy_threshold
  }

  # Stickiness configuration
  dynamic "stickiness" {
    for_each = var.enable_stickiness ? [1] : []
    content {
      type            = "lb_cookie"
      cookie_duration = var.stickiness_cookie_duration
      enabled         = true
    }
  }

  tags = {
    Name        = "${var.environment}-tg"
    Environment = var.environment
    ManagedBy   = "terraform"
  }
}

# HTTP Listener
resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.main.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.main.arn
  }

  tags = {
    Name        = "${var.environment}-alb-listener-http"
    Environment = var.environment
    ManagedBy   = "terraform"
  }
}

# HTTPS Listener (optional)
resource "aws_lb_listener" "https" {
  count = var.enable_ssl ? 1 : 0
  
  load_balancer_arn = aws_lb.main.arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = var.ssl_policy
  certificate_arn   = var.certificate_arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.main.arn
  }

  tags = {
    Name        = "${var.environment}-alb-listener-https"
    Environment = var.environment
    ManagedBy   = "terraform"
  }
}

# Security Group for ALB
resource "aws_security_group" "alb" {
  name_prefix = "${var.environment}-alb-sg"
  description = "Security group for Application Load Balancer"
  vpc_id      = var.vpc_id

  # HTTP Ingress
  ingress {
    description = "HTTP traffic from internet"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # HTTPS Ingress
  ingress {
    description = "HTTPS traffic from internet"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # All Outbound Traffic
  egress {
    description = "Allow all outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "${var.environment}-alb-sg"
    Environment = var.environment
    ManagedBy   = "terraform"
  }
}
