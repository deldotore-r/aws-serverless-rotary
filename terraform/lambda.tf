###############################################################################
# Lambda Function Configuration
#
# Este arquivo define a função Lambda responsável por processar os formulários
# do site do Rotary, bem como o papel (IAM Role) e as permissões necessárias.
#
# Boas práticas aplicadas:
# - Princípio do menor privilégio
# - Uso de environment variables
# - Deploy automático via Terraform ao detectar mudanças no código
# - Tags para rastreabilidade
###############################################################################

##############################
# 1. Preparar o código da Lambda
# Compacta o diretório do código em um arquivo .zip para upload automático
##############################

data "archive_file" "lambda_zip" {
  type        = "zip"
  source_dir  = "${path.module}/lambda/contact_form_handler"      # Caminho da função Lambda
  output_path = "${path.module}/lambda/contact_form_handler_payload.zip"
}

##############################
# 2. IAM Role: Permite que a Lambda execute tarefas na AWS
##############################

resource "aws_iam_role" "lambda_exec" {
  name = "rotary_lambda_exec_role"

  # Política que permite ao serviço Lambda assumir este papel
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

  # Tags para identificação no console AWS
  tags = {
    Project     = "Rotary Serverless"
    Environment = "dev"
  }
}

##############################
# 3. IAM Role Policy: Permissões específicas da Lambda
##############################

resource "aws_iam_role_policy" "lambda_dynamo_policy" {
  name = "rotary_lambda_dynamo_policy"
  role = aws_iam_role.lambda_exec.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        # Permite que a Lambda escreva itens na tabela DynamoDB
        Action   = ["dynamodb:PutItem"],
        Effect   = "Allow",
        Resource = aws_dynamodb_table.form_messages.arn
      },
      {
        # Permite criar logs no CloudWatch (necessário para manutenção e debugging)
        Action   = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ],
        Effect   = "Allow",
        Resource = "arn:aws:logs:*:*:*"
      }
    ]
  })
}

##############################
# 4. Definição da Função Lambda
##############################

resource "aws_lambda_function" "form_processor" {
  function_name    = "rotary-form-processor"
  filename         = data.archive_file.lambda_zip.output_path
  source_code_hash = data.archive_file.lambda_zip.output_base64sha256
  role             = aws_iam_role.lambda_exec.arn
  handler          = "index.lambda_handler"
  runtime          = "python3.9"

  # Configurações de ambiente
  environment {
    variables = {
      TABLE_NAME = aws_dynamodb_table.form_messages.name
    }
  }

  # Controle de recursos da Lambda
  timeout      = 10    # segundos, ajuste se necessário
  memory_size  = 128   # MB, ajuste se necessário

  # Tags para rastreabilidade e billing
  tags = {
    Project     = "Rotary Serverless"
    Environment = "dev"
    Description = "Processador de formulário do site do Rotary"
  }
}
