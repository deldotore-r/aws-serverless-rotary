
# 1. Definição do Bucket S3 que armazenará os arquivos do site (HTML, CSS, JS).

resource "aws_s3_bucket" "website_bucket" {
  bucket = "rotary-club-guarda-site" # O nome deve ser único em toda a AWS

  tags = {
    Name        = "Bucket do Website Estático"
    Description = "Hospeda o frontend do Rotary Club da Guarda"
  }
}

# 2. Configuração do Bucket para modo "Website".
# Isto diz à AWS que o bucket deve procurar um arquivo 'index.html' ao ser acessado.

resource "aws_s3_bucket_website_configuration" "config" {
  bucket = aws_s3_bucket.website_bucket.id

  index_document {
    suffix = "index.html"
  }
}

# 3. Gestão de Bloqueio de Acesso Público.
# Por padrão, a AWS bloqueia tudo. Para um site, precisamos permitir a leitura pública.

resource "aws_s3_bucket_public_access_block" "public_access" {
  bucket = aws_s3_bucket.website_bucket.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

# 4. Política do Bucket (Bucket Policy).
# Esta é a "permissão de leitura" que permite que qualquer pessoa na internet veja o site.

resource "aws_s3_bucket_policy" "allow_public_access" {
  bucket = aws_s3_bucket.website_bucket.id
  
  # Garante que esta política só seja aplicada após o desbloqueio do acesso público acima.

  depends_on = [aws_s3_bucket_public_access_block.public_access]

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "PublicReadGetObject"
        Effect    = "Allow"
        Principal = "*"
        Action    = "s3:GetObject"
        Resource  = "${aws_s3_bucket.website_bucket.arn}/*"
      },
    ]
  })
}

