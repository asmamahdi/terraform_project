# S3 Module - Storage Buckets
# Owner: Asma Mahdi
# Purpose: Reusable S3 buckets for assets and logs

# S3 Bucket for Application Assets
resource "aws_s3_bucket" "assets" {
  bucket = var.assets_bucket_name

  tags = {
    Name        = var.assets_bucket_name
    Environment = var.environment
    Purpose     = "app-assets"
    ManagedBy   = "terraform"
  }
}

# S3 Bucket Versioning for Assets
resource "aws_s3_bucket_versioning" "assets" {
  bucket = aws_s3_bucket.assets.id
  versioning_configuration {
    status = var.enable_assets_versioning ? "Enabled" : "Disabled"
  }
}

# S3 Bucket Encryption for Assets
resource "aws_s3_bucket_server_side_encryption_configuration" "assets" {
  bucket = aws_s3_bucket.assets.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# S3 Bucket Public Access Block for Assets
resource "aws_s3_bucket_public_access_block" "assets" {
  bucket = aws_s3_bucket.assets.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# S3 Bucket Lifecycle Configuration for Assets
resource "aws_s3_bucket_lifecycle_configuration" "assets" {
  bucket = aws_s3_bucket.assets.id

  rule {
    id     = "assets_lifecycle"
    status = "Enabled"

    filter {
      prefix = ""
    }

    transition {
      days          = var.assets_transition_to_ia_days
      storage_class = "STANDARD_IA"
    }

    transition {
      days          = var.assets_transition_to_glacier_days
      storage_class = "GLACIER"
    }

    noncurrent_version_expiration {
      noncurrent_days = var.assets_noncurrent_version_expiration_days
    }
  }
}

# S3 Bucket for Application Logs
resource "aws_s3_bucket" "logs" {
  bucket = var.logs_bucket_name

  tags = {
    Name        = var.logs_bucket_name
    Environment = var.environment
    Purpose     = "app-logs"
    ManagedBy   = "terraform"
  }
}

# S3 Bucket Versioning for Logs
resource "aws_s3_bucket_versioning" "logs" {
  bucket = aws_s3_bucket.logs.id
  versioning_configuration {
    status = var.enable_logs_versioning ? "Enabled" : "Disabled"
  }
}

# S3 Bucket Encryption for Logs
resource "aws_s3_bucket_server_side_encryption_configuration" "logs" {
  bucket = aws_s3_bucket.logs.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# S3 Bucket Public Access Block for Logs
resource "aws_s3_bucket_public_access_block" "logs" {
  bucket = aws_s3_bucket.logs.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# S3 Bucket Lifecycle Configuration for Logs
resource "aws_s3_bucket_lifecycle_configuration" "logs" {
  bucket = aws_s3_bucket.logs.id

  rule {
    id     = "logs_lifecycle"
    status = "Enabled"

    filter {
      prefix = ""
    }

    expiration {
      days = var.logs_expiration_days
    }

    noncurrent_version_expiration {
      noncurrent_days = var.logs_noncurrent_version_expiration_days
    }
  }
}

# S3 Bucket Policy for ALB Access Logs (if ALB is enabled)
resource "aws_s3_bucket_policy" "logs" {
  count = var.enable_alb_logs ? 1 : 0
  
  bucket = aws_s3_bucket.logs.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          AWS = "arn:aws:iam::${data.aws_elb_service_account.main[0].id}:root"
        }
        Action   = "s3:PutObject"
        Resource = "${aws_s3_bucket.logs.arn}/alb-access-logs/*"
      },
      {
        Effect = "Allow"
        Principal = {
          Service = "delivery.logs.amazonaws.com"
        }
        Action   = "s3:PutObject"
        Resource = "${aws_s3_bucket.logs.arn}/alb-access-logs/*"
        Condition = {
          StringEquals = {
            "s3:x-amz-acl" = "bucket-owner-full-control"
          }
        }
      },
      {
        Effect = "Allow"
        Principal = {
          Service = "delivery.logs.amazonaws.com"
        }
        Action   = "s3:GetBucketAcl"
        Resource = aws_s3_bucket.logs.arn
      }
    ]
  })

  depends_on = [aws_s3_bucket_public_access_block.logs]
}

# Data source for ELB service account (for ALB logs)
data "aws_elb_service_account" "main" {
  count = var.enable_alb_logs ? 1 : 0
}
