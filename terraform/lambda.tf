###############################################################################
# Lambda Function Configuration
#
# Este arquivo define a função Lambda responsável por processar os formulários
# do site do Rotary, bem como o papel (IAM Role) e as permissões necessárias.
###############################################################################

##############################
# 1. Preparar o código da Lambda
##############################

data "archive_file" "lambda_zip" {
  type        = "zip"
  source_dir  = "${path.module}/lambda/contact_form_handler"
  output_path = "${path.module}/lambda/contact_form_handler_payload.zip"
}

##############################
# 2. IAM Role: Permite que a Lambda execute tarefas na AWS
##############################

resource "aws_iam_role" "lambda_exec" {
  name = "rotary_lambda_exec_role"

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

  tags = {
    Project     = "Rotary Serverless"
    Environment = "dev"
  }
}

##############################
# 3. IAM Role Policy: Permissões para DynamoDB, CloudWatch e SNS
##############################

resource "aws_iam_role_policy" "lambda_combined_policy" {
  name = "rotary_lambda_policy"
  role = aws_iam_role.lambda_exec.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        # Permissão para o DynamoDB
        Action   = ["dynamodb:PutItem"],
        Effect   = "Allow",
        Resource = aws_dynamodb_table.form_messages.arn
      },
      {
        # Permissão para Logs
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ],
        Effect   = "Allow",
        Resource = "arn:aws:logs:*:*:*"
      },
      {
        # Permissão para Notificações SNS
        Action   = "sns:Publish",
        Effect   = "Allow",
        Resource = aws_sns_topic.form_notifications.arn
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

  # Configurações de ambiente - Essencial para o código Python funcionar
  environment {
    variables = {
      TABLE_NAME    = aws_dynamodb_table.form_messages.name
      SNS_TOPIC_ARN = aws_sns_topic.form_notifications.arn
    }
  }

  timeout     = 10
  memory_size = 128

  tags = {
    Project     = "Rotary Serverless"
    Environment = "dev"
    Description = "Processador de formulário com notificações SNS"
  }
}

##############################
# 5. Configuração de Notificações (SNS)
##############################

resource "aws_sns_topic" "form_notifications" {
  name = "rotary-form-notifications"
}

resource "aws_sns_topic_subscription" "email_target" {
  topic_arn = aws_sns_topic.form_notifications.arn
  protocol  = "email"
  endpoint  = var.notification_email
}