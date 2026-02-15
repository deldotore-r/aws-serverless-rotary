provider "aws" {
  region  = "us-east-1"
  profile = "rotary"
}

# 1. Recurso principal do Bucket (agora mais limpo)
resource "aws_s3_bucket" "terraform_state" {
  bucket = "rotary-guarda-terraform-state"

  # Ativa o suporte para Object Lock no nível do bucket
  object_lock_enabled = true

  lifecycle {
    prevent_destroy = true
  }

  tags = {
    Name        = "Terraform State Bucket"
    Environment = "Bootstrap"
    Owner       = "Rotary Club da Guarda"
    ManagedBy   = "Terraform"
  }
}

# 2. Habilita versionamento (recurso separado)
resource "aws_s3_bucket_versioning" "enabled" {
  bucket = aws_s3_bucket.terraform_state.id
  versioning_configuration {
    status = "Enabled"
  }
}

# 3. Criptografia (recurso separado)
resource "aws_s3_bucket_server_side_encryption_configuration" "default" {
  bucket = aws_s3_bucket.terraform_state.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# 4. CONFIGURAÇÃO MODERNA DO OBJECT LOCK (O ajuste que você pediu)
resource "aws_s3_bucket_object_lock_configuration" "state_lock" {
  bucket = aws_s3_bucket.terraform_state.id

  rule {
    default_retention {
      mode = "GOVERNANCE"
      days = 30
    }
  }
}