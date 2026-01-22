###############################################################################
# Terraform Remote State Configuration
#
# Este arquivo configura o armazenamento do estado do Terraform em um backend
# remoto no Amazon S3.
#
# O uso de estado remoto é fundamental para:
# - Evitar perda do arquivo terraform.tfstate
# - Permitir reconstrução da infraestrutura a partir de qualquer máquina
# - Manter consistência entre múltiplas execuções do Terraform
#
# Neste projeto, o estado é armazenado em um bucket S3 dedicado, com criptografia
# habilitada.
###############################################################################

terraform {
  backend "s3" {

    # Bucket S3 previamente criado exclusivamente para armazenar o estado
    # do Terraform. Este bucket NÃO armazena dados da aplicação.
    bucket = "rotary-infra-terraform-state"

    # Caminho (key) dentro do bucket onde o arquivo terraform.tfstate será salvo.
    # Usar um prefixo (serverless/) evita conflitos caso outros projetos utilizem
    # o mesmo bucket no futuro.
    key = "serverless/terraform.tfstate"

    # Região AWS onde o bucket S3 está localizado.
    # Deve corresponder exatamente à região do bucket.
    region = "us-east-1"

    # Habilita criptografia do estado em repouso no S3.
    # Recomendado mesmo para projetos pequenos.
    encrypt = true

    # Observação sobre locking:
    # Versões modernas do Terraform suportam locking nativo no backend S3
    # através de operações condicionais.
    #
    # Para este projeto (uso individual, sem CI/CD), esse mecanismo é suficiente.
    # Em cenários com múltiplos operadores ou pipelines paralelos, recomenda-se
    # complementar com DynamoDB para locking explícito.
  }
}

