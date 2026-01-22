###############################################################################
# API Gateway Configuration
#
# Define a API HTTP que expõe a função Lambda para o formulário de contato.
# Boas práticas aplicadas:
# - HTTP API (mais barata que REST API clássico)
# - CORS configurado via variável
# - Apenas métodos necessários habilitados (POST)
# - Permissões Lambda explícitas
# - Tags consistentes com outros recursos (Lambda, DynamoDB)
###############################################################################

##############################
# Variáveis recomendadas
# - CORS_ORIGINS: Domínios permitidos para requisições do browser
# - ENVIRONMENT: "dev", "staging", "prod"
##############################

variable "cors_origins" {
  description = "Domínios permitidos para requisições cross-origin"
  type        = list(string)
  default     = ["*"] # Para testes; em produção, substitua pelo domínio do site
}

variable "environment" {
  description = "Ambiente do deploy"
  type        = string
  default     = "prod"
}

##############################
# 1. Criação da API HTTP
##############################

resource "aws_apigatewayv2_api" "form_api" {
  name          = "rotary-contact-api"
  protocol_type = "HTTP"

  cors_configuration {
    allow_origins = var.cors_origins
    allow_methods = ["POST", "OPTIONS"]
    allow_headers = ["content-type"]
  }

  # Tags unificadas
  tags = {
    Project     = "Rotary Serverless"
    Environment = var.environment
    Description = "API para o formulário de contato do Rotary"
  }
}

##############################
# 2. Stage $default
# Permite deploy automático sem prefixos na URL
##############################

resource "aws_apigatewayv2_stage" "default" {
  api_id      = aws_apigatewayv2_api.form_api.id
  name        = "$default"
  auto_deploy = true

  tags = {
    Project     = "Rotary Serverless"
    Environment = var.environment
  }
}

##############################
# 3. Integração Lambda
##############################

resource "aws_apigatewayv2_integration" "lambda_integration" {
  api_id           = aws_apigatewayv2_api.form_api.id
  integration_type = "AWS_PROXY"
  integration_uri  = aws_lambda_function.form_processor.invoke_arn
}

##############################
# 4. Rota POST /contato
##############################

resource "aws_apigatewayv2_route" "post_route" {
  api_id    = aws_apigatewayv2_api.form_api.id
  route_key = "POST /contato"
  target    = "integrations/${aws_apigatewayv2_integration.lambda_integration.id}"
}

##############################
# 5. Permissão Lambda
# Permite que o API Gateway invoque a Lambda
##############################

resource "aws_lambda_permission" "api_gw" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.form_processor.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.form_api.execution_arn}/*/*"
}
