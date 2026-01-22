###############################################################################
# Outputs do Terraform
#
# Exibe informações úteis após o deploy, para fácil referência e integração
###############################################################################

# URL do site estático hospedado no S3
output "s3_website_url" {
  description = "URL pública do website hospedado no bucket S3"
  value       = aws_s3_bucket_website_configuration.config.website_endpoint
}

# Nome do bucket S3
output "s3_bucket_name" {
  description = "Nome do bucket S3 que hospeda o website"
  value       = aws_s3_bucket.website_bucket.id
}

# URL da API Gateway (HTTP API)
output "api_gateway_url" {
  description = "Endpoint HTTP da API Gateway que processa o formulário"
  value       = aws_apigatewayv2_api.form_api.api_endpoint
}

# Nome da função Lambda que processa o formulário
output "lambda_function_name" {
  description = "Nome da função Lambda que recebe os dados do formulário"
  value       = aws_lambda_function.form_processor.function_name
}

# Nome da tabela DynamoDB que armazena as mensagens
output "dynamodb_table_name" {
  description = "Nome da tabela DynamoDB onde as mensagens são armazenadas"
  value       = aws_dynamodb_table.form_messages.name
}

# ARN da tabela DynamoDB (para referência em outras integrações)
output "dynamodb_table_arn" {
  description = "ARN da tabela DynamoDB (pode ser usada em permissões)"
  value       = aws_dynamodb_table.form_messages.arn
}


