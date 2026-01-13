
# Configuracao do Estado Remoto (Remote State).
# Isso evita que o arquivo terraform.tfstate se perca se o seu computador quebrar.

terraform {
  backend "s3" {
    bucket         = "rotary-infra-terraform-state" # O nome do seu bucket de estado ja criado
    key            = "serverless/terraform.tfstate" # Caminho dentro do bucket
    region         = "us-east-1"
    encrypt        = true                           # Ativa criptografia por seguranca

    # Nota: Como estamos em um projeto solo, o S3 Native Locking ja ajuda a proteger o arquivo.

  }
}

