
# 1. Criação da API propriamente dita. 
# O protocolo HTTP é escolhido por ser mais barato e simples que o REST clássico da AWS.

resource "aws_apigatewayv2_api" "form_api" {
  name          = "rotary-contact-api"
  protocol_type = "HTTP"
  
  # CORS: Essencial para que o navegador permita que o site (S3) envie dados para esta API.

  cors_configuration {
    allow_origins = ["*"] # Em produção, substitua pelo domínio final do Rotary
    allow_methods = ["POST", "OPTIONS"]
    allow_headers = ["content-type"]
  }

  tags = {
    Description = "API para o formulario de contato do Rotary"
  }
}

# 2. Configuração do "Estágio" (Stage). 
# O estágio $default permite que a API seja acessada imediatamente sem prefixos na URL.

resource "aws_apigatewayv2_stage" "default" {
  api_id      = aws_apigatewayv2_api.form_api.id
  name        = "$default"
  auto_deploy = true
}

# 3. Integração: Conecta o API Gateway à função Lambda.
# Quando a API recebe um hit, ela sabe que deve "chamar" a Lambda que processa o banco.

resource "aws_apigatewayv2_integration" "lambda_integration" {
  api_id           = aws_apigatewayv2_api.form_api.id
  integration_type = "AWS_PROXY"
  integration_uri  = aws_lambda_function.form_processor.invoke_arn # Referência à Lambda
}

# 4. Rota: Define o "caminho" da URL.
# Exemplo: https://sua-api.com/contato. Somente o método POST é permitido por segurança.

resource "aws_apigatewayv2_route" "post_route" {
  api_id    = aws_apigatewayv2_api.form_api.id
  route_key = "POST /contato"
  target    = "integrations/${aws_apigatewayv2_integration.lambda_integration.id}"
}

# 5. Permissão: Autoriza o API Gateway a executar a sua Lambda.
# Por padrão, um serviço AWS não pode chamar outro sem uma permissão explícita.

resource "aws_lambda_permission" "api_gw" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.form_processor.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.form_api.execution_arn}/*/*"
}


