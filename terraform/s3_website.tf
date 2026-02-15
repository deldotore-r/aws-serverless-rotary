###############################################################################
# S3 Website Configuration
#
# Define o bucket S3 que hospeda o frontend do Rotary Club da Guarda
# para acesso público via browser.
# Boas práticas:
# - Permissões públicas configuradas de forma explícita
# - Configuração de website estático (index.html)
# - Tags consistentes com outros recursos
###############################################################################

##############################
# 1. Bucket S3
##############################

resource "aws_s3_bucket" "website_bucket" {
  bucket = "rotary-club-guarda-site" # Deve ser único globalmente na AWS

  # Tags unificadas para rastreabilidade
  tags = {
    Project     = "Rotary Serverless"
    Environment = "prod"
    Name        = "Bucket do Website Estático"
    Description = "Hospeda o frontend do Rotary Club da Guarda"
  }
}

##############################
# 2. Configuração do Bucket como Website Estático
##############################

resource "aws_s3_bucket_website_configuration" "config" {
  bucket = aws_s3_bucket.website_bucket.id

  index_document {
    suffix = "index.html" # Arquivo principal ao acessar o bucket via browser
  }

  # Opcional: adicionar erro customizado
  # error_document {
  #   key = "404.html"
  # }
}

##############################
# 3. Desbloqueio do Acesso Público
# Necessário para que qualquer usuário consiga acessar os arquivos
##############################

resource "aws_s3_bucket_public_access_block" "public_access" {
  bucket = aws_s3_bucket.website_bucket.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

##############################
# 4. Política do Bucket: Permissão de Leitura Pública
##############################

resource "aws_s3_bucket_policy" "allow_public_access" {
  bucket = aws_s3_bucket.website_bucket.id

  depends_on = [aws_s3_bucket_public_access_block.public_access]

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "PublicReadGetObject"
        Effect    = "Allow"
        Principal = "*"            # Todos os usuários
        Action    = "s3:GetObject" # Apenas leitura de objetos
        Resource  = "${aws_s3_bucket.website_bucket.arn}/*"
      }
    ]
  })
}
