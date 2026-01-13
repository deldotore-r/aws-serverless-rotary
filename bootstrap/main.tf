
provider "aws" {
  region = "us-east-1"
}

# Bucket para armazenar o arquivo .tfstate

resource "aws_s3_bucket" "terraform_state" {
  bucket = "rotary-guarda-terraform-state" # Certifique-se de que este nome seja único na AWS
  
  # Proteção extra: impede que o Terraform apague este bucket por engano

  lifecycle {
    prevent_destroy = true
  }
}

# Ativa o versionamento para podermos recuperar estados anteriores caso algo corrompa

resource "aws_s3_bucket_versioning" "enabled" {
  bucket = aws_s3_bucket.terraform_state.id
  versioning_configuration {
    status = "Enabled"
  }
}

# Ativa a criptografia nativa para proteger os dados sensíveis do estado

resource "aws_s3_bucket_server_side_encryption_configuration" "default" {
  bucket = aws_s3_bucket.terraform_state.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

