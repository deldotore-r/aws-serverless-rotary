provider "aws" {
  region = "us-east-1"
}

# 1. Bucket S3 para armazenar o arquivo terraform.tfstate
resource "aws_s3_bucket" "terraform_state" {
  bucket = "rotary-guarda-terraform-state" # Deve ser único globalmente

  # Impede destruição acidental do bucket
  lifecycle {
    prevent_destroy = true
  }

  # 2. Habilita o Object Lock para que S3 Native Locking funcione
  object_lock_configuration {
    object_lock_enabled = "Enabled"
    rule {
      default_retention {
        mode  = "GOVERNANCE" # Modo mais flexível, pode ser sobrescrito por admins
        days  = 30            # Retenção mínima para evitar sobrescritas acidentais
      }
    }
  }

  # 3. Tags para identificação e gestão de custos
  tags = {
    Name        = "Terraform State Bucket"
    Environment = "Bootstrap"
    Owner       = "Rotary Club da Guarda"
    ManagedBy   = "Terraform"
  }
}

# 4. Habilita versionamento para podermos recuperar estados anteriores
resource "aws_s3_bucket_versioning" "enabled" {
  bucket = aws_s3_bucket.terraform_state.id
  versioning_configuration {
    status = "Enabled"
  }
}

# 5. Criptografia nativa para proteger dados sensíveis do estado
resource "aws_s3_bucket_server_side_encryption_configuration" "default" {
  bucket = aws_s3_bucket.terraform_state.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

