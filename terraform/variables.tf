###############################################################################
# Variáveis do Projeto
#
# Todas as variáveis que definem nomes, regiões, ambiente e CORS
# para padronizar recursos no Terraform.
###############################################################################

# Região AWS
variable "aws_region" {
  description = "Região da AWS onde a infraestrutura será provisionada"
  type        = string
  default     = "us-east-1" # Norte da Virginia
}

# Nome base do projeto, usado para tagging e nomes de recursos
variable "project_name" {
  description = "Nome base do projeto para tagging e nomes de recursos"
  type        = string
  default     = "rotary-club-guarda"
}

# Ambiente: dev, staging ou prod
variable "environment" {
  description = "Ambiente de deploy"
  type        = string
  default     = "prod"
}

# Domínios permitidos para CORS (usado no API Gateway)
variable "cors_origins" {
  description = "Lista de domínios permitidos para requisições cross-origin"
  type        = list(string)
  default     = ["*"] # Para testes. Em produção, usar domínio do site.
}

# Nome da tabela DynamoDB para mensagens do formulário
variable "dynamodb_table_name" {
  description = "Nome da tabela DynamoDB que armazenará mensagens do formulário"
  type        = string
  default     = "rotary-form-messages"
}

# Nome do bucket S3 do site
variable "s3_bucket_name" {
  description = "Nome do bucket S3 que hospedará o frontend do site"
  type        = string
  default     = "rotary-club-guarda-site"
}

# Nome da função Lambda
variable "lambda_function_name" {
  description = "Nome da função Lambda que processa o formulário"
  type        = string
  default     = "rotary-form-processor"
}


