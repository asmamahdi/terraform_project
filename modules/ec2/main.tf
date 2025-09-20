# EC2 Module - Enhanced Configuration for Ansible Integration
# This module creates EC2 instances with security groups and IAM roles

# Create IAM Role for EC2 instances
resource "aws_iam_role" "ec2_role" {
  name = "${var.environment}-ec2-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })

  tags = {
    Name        = "${var.environment}-ec2-role"
    Environment = var.environment
    ManagedBy   = "terraform"
  }
}

# Attach policies to the IAM role
resource "aws_iam_role_policy_attachment" "ec2_ssm" {
  role       = aws_iam_role.ec2_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_role_policy_attachment" "ec2_cloudwatch" {
  role       = aws_iam_role.ec2_role.name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
}

# Create instance profile
resource "aws_iam_instance_profile" "ec2_profile" {
  name = "${var.environment}-ec2-profile"
  role = aws_iam_role.ec2_role.name

  tags = {
    Name        = "${var.environment}-ec2-profile"
    Environment = var.environment
    ManagedBy   = "terraform"
  }
}

# Create Security Group for EC2 instances
resource "aws_security_group" "ec2" {
  name_prefix = "${var.environment}-ec2-sg"
  vpc_id      = var.vpc_id
  
  # SSH access (for Ansible)
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = var.allowed_ssh_cidrs
    description = "SSH access for Ansible"
  }
  
  # HTTP access
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "HTTP access"
  }
  
  # HTTPS access
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "HTTPS access"
  }
  
  # Application port (customizable)
  dynamic "ingress" {
    for_each = var.application_ports
    content {
      from_port   = ingress.value
      to_port     = ingress.value
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
      description = "Application port ${ingress.value}"
    }
  }
  
  # All outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "All outbound traffic"
  }
  
  tags = {
    Name        = "${var.environment}-ec2-sg"
    Environment = var.environment
    ManagedBy   = "terraform"
  }
}

# Create Launch Template for Auto Scaling
resource "aws_launch_template" "main" {
  name_prefix   = "${var.environment}-ec2-"
  image_id      = var.ami_id
  instance_type = var.instance_type
  # key_name      = var.key_name  # Commented out for testing

  vpc_security_group_ids = [aws_security_group.ec2.id]
  iam_instance_profile {
    name = aws_iam_instance_profile.ec2_profile.name
  }

  user_data = base64encode(templatefile("${path.module}/user_data.sh", {
    environment = var.environment
    app_name    = var.app_name
  }))

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name        = "${var.environment}-ec2"
      Environment = var.environment
      ManagedBy   = "terraform"
      AnsibleManaged = "true"
    }
  }

  tags = {
    Name        = "${var.environment}-ec2-template"
    Environment = var.environment
    ManagedBy   = "terraform"
  }
}

# Create Auto Scaling Group
resource "aws_autoscaling_group" "main" {
  name                = "${var.environment}-asg"
  vpc_zone_identifier = var.subnet_ids
  target_group_arns   = var.target_group_arns
  health_check_type   = "ELB"
  health_check_grace_period = 300

  min_size         = var.min_size
  max_size         = var.max_size
  desired_capacity = var.desired_capacity

  launch_template {
    id      = aws_launch_template.main.id
    version = "$Latest"
  }

  tag {
    key                 = "Name"
    value               = "${var.environment}-asg"
    propagate_at_launch = false
  }

  tag {
    key                 = "Environment"
    value               = var.environment
    propagate_at_launch = true
  }

  tag {
    key                 = "ManagedBy"
    value               = "terraform"
    propagate_at_launch = true
  }

  tag {
    key                 = "AnsibleManaged"
    value               = "true"
    propagate_at_launch = true
  }
}

# Create CloudWatch Log Group
resource "aws_cloudwatch_log_group" "ec2" {
  name              = "/aws/ec2/${var.environment}"
  retention_in_days = var.log_retention_days

  tags = {
    Name        = "${var.environment}-ec2-logs"
    Environment = var.environment
    ManagedBy   = "terraform"
  }
}