
# 1. URL pública do site no S3.
# É através deste link que os membros do Rotary Club da Guarda acessarão o portal.

output "website_url" {
  description = "URL publica do site hospedado no S3"
  value       = "http://${aws_s3_bucket_website_configuration.config.website_endpoint}"
}

# 2. Endpoint do API Gateway.
# IMPORTANTE: Esta URL deve ser copiada e colada no código JavaScript do seu formulário (frontend).

output "api_gateway_url" {
  description = "URL base da API para o formulario"
  value       = "${aws_apigatewayv2_stage.default.invoke_url}/contato"
}

# 3. Nome da tabela no DynamoDB.
# Facilita a localização rápida do banco de dados no console da AWS.

output "dynamodb_table_name" {
  description = "Nome da tabela de mensagens"
  value       = aws_dynamodb_table.form_messages.name
}

# 4. Nome da função Lambda.
# Útil para caso seja necessário consultar os logs no CloudWatch.

output "lambda_function_name" {
  description = "Nome da funcao processadora"
  value       = aws_lambda_function.form_processor.function_name
}

