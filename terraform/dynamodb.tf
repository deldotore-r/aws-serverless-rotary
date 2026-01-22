###############################################################################
# DynamoDB Table: Armazena mensagens enviadas pelo formulário de contato
#
# DynamoDB escolhido pela alta disponibilidade, escalabilidade automática e custo mínimo.
###############################################################################

resource "aws_dynamodb_table" "form_messages" {
  name         = "rotary-form-messages"
  billing_mode = "PAY_PER_REQUEST"   # Paga apenas quando há uso
  hash_key     = "id"                 # Chave primária única para cada mensagem

  # Definição do atributo da chave primária
  attribute {
    name = "id"
    type = "S"  # 'S' = String
  }

  # Tags para rastreabilidade de custos e identificação do recurso
  tags = {
    Name        = "Tabela de Mensagens do Site"
    Project     = "Rotary Serverless"
    Owner       = "Rotary Club da Guarda"
    ManagedBy   = "Terraform"
    Environment = "prod"
  }
}


