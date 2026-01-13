import json
import boto3
import uuid
import os
from datetime import datetime  # Importação que faltava

# Inicializa o cliente do DynamoDB
dynamodb = boto3.resource("dynamodb")

# Em vez de fixar o nome, pegamos a variável definida no Terraform (lambda.tf)
# Isso permite que o sucessor mude o nome da tabela sem mexer no código Python.
TABLE_NAME = os.environ.get("TABLE_NAME", "rotary-form-messages")
table = dynamodb.Table(TABLE_NAME)


def lambda_handler(event, context):
    """
    Função principal executada pela AWS sempre que o formulário é enviado.
    """
    try:
        # 1. Extração dos dados enviados pelo formulário
        if "body" not in event:
            raise ValueError("Corpo da requisição vazio")

        body = json.loads(event["body"])

        # 2. Montagem do Item para o DynamoDB
        # Usamos o .get() com alternativas para garantir compatibilidade
        item = {
            "id": str(uuid.uuid4()),
            "nome": body.get("nome") or body.get("name") or "Não informado",
            "email": body.get("email") or "Não informado",
            "telefone": body.get("phone") or body.get("telefone") or "Não informado",
            "assunto": body.get("subject") or body.get("assunto") or "Geral",
            "mensagem": body.get("message") or body.get("mensagem") or "",
            "data_envio": datetime.now().isoformat(),  # ISO format é padrão para bancos NoSQL
        }

        # 3. Persistência no DynamoDB
        table.put_item(Item=item)

        # 4. Resposta de Sucesso com cabeçalhos CORS
        return {
            "statusCode": 200,
            "headers": {
                "Access-Control-Allow-Origin": "*",  # Permite que o site no S3 acesse a API
                "Content-Type": "application/json",
            },
            "body": json.dumps(
                {
                    "status": "sucesso",
                    "mensagem": "Obrigado! O Rotary Club da Guarda recebeu a sua mensagem.",
                }
            ),
        }

    except Exception as e:
        # Registra o erro detalhado no CloudWatch para auditoria
        print(f"Erro detectado: {str(e)}")
        return {
            "statusCode": 500,
            "headers": {
                "Access-Control-Allow-Origin": "*",
                "Content-Type": "application/json",
            },
            "body": json.dumps(
                {"status": "erro", "detalhe": "Falha interna ao processar mensagem."}
            ),
        }
