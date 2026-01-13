
# Definição da tabela onde as mensagens do formulário de contato serão armazenadas.
# Escolhemos o DynamoDB pela alta disponibilidade e custo virtualmente zero neste cenário.

resource "aws_dynamodb_table" "form_messages" {
  name           = "rotary-form-messages"
  
  # PAY_PER_REQUEST: Não pagamos valor mensal fixo. 
  # A AWS só cobra frações de centavos se alguém enviar o formulário.

  billing_mode   = "PAY_PER_REQUEST" 

  # O 'id' é a chave primária. Cada mensagem terá um identificador único exclusivo.

  hash_key       = "id"

  # Definição do atributo da chave primária.

  attribute {
    name = "id"
    type = "S" # 'S' significa String (texto)
  }

  # Tags ajudam a identificar os custos e a quem o recurso pertence no painel da AWS.

  tags = {
    Name        = "Tabela de Mensagens do Site"
    Owner       = "Rotary Club da Guarda"
    ManagedBy   = "Terraform"
    Environment = "Producao"
  }
}

