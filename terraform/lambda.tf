
# 1. Preparação do código: O Terraform compacta a pasta do script em um arquivo .zip
# Isso automatiza o envio do seu código Python para a AWS sempre que você alterar o index.py.

data "archive_file" "lambda_zip" {
  type        = "zip"
  source_dir  = "${path.module}/../lambda_function"
  output_path = "${path.module}/lambda_function_payload.zip"
}

# 2. Perfil de Execução (IAM Role): Define o que a função Lambda "é" perante a AWS.

resource "aws_iam_role" "lambda_exec" {
  name = "rotary_lambda_exec_role"

  # Permite que o serviço Lambda assuma este papel para executar as tarefas.

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "lambda.amazonaws.com"
      }
    }]
  })
}

# 3. Permissões de escrita: Autoriza a Lambda a gravar dados especificamente na tabela do Rotary.
# Seguimos o Princípio do Menor Privilégio (apenas permissão de PutItem na tabela correta).

resource "aws_iam_role_policy" "lambda_dynamo_policy" {
  name = "rotary_lambda_dynamo_policy"
  role = aws_iam_role.lambda_exec.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "dynamodb:PutItem"
        ]
        Effect   = "Allow"
        Resource = aws_dynamodb_table.form_messages.arn # Referência direta ao arquivo dynamodb.tf
      },
      {

        # Permite que a Lambda crie logs no CloudWatch (essencial para manutenção futura).

        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Effect   = "Allow"
        Resource = "arn:aws:logs:*:*:*"
      }
    ]
  })
}

# 4. A Função Lambda: O recurso que executa o seu código Python.

resource "aws_lambda_function" "form_processor" {
  filename         = data.archive_file.lambda_zip.output_path
  function_name    = "rotary-form-processor"
  role             = aws_iam_role.lambda_exec.arn
  handler          = "index.lambda_handler" # Nome do arquivo (index) + nome da função (lambda_handler)
  source_code_hash = data.archive_file.lambda_zip.output_base64sha256 # Detecta mudanças no código
  runtime          = "python3.9"

  environment {
    variables = {
      TABLE_NAME = aws_dynamodb_table.form_messages.name
    }
  }

  tags = {
    Description = "Processador de formulario do site do Rotary"
  }
}

