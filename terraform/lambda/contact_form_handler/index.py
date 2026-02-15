import json
import boto3
import uuid
import os
from datetime import datetime

# Inicialização
dynamodb = boto3.resource("dynamodb")
TABLE_NAME = os.environ.get("TABLE_NAME", "rotary-form-messages")
table = dynamodb.Table(TABLE_NAME)
REQUIRED_FIELDS = ["nome", "email", "mensagem"]

def lambda_handler(event, context):
    """
    Processa o formulário com suporte robusto a CORS e Payload 1.0/2.0.
    """
    
    # 1. Identificar o método HTTP de forma segura para Payload 1.0 e 2.0
    # Na v1.0 é event['httpMethod'], na v2.0 é event['requestContext']['http']['method']
    method = event.get('httpMethod') or event.get('requestContext', {}).get('http', {}).get('method')
    
    # CORS Headers padrão
    headers = {
        "Content-Type": "application/json",
        "Access-Control-Allow-Origin": "*",
        "Access-Control-Allow-Headers": "Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token",
        "Access-Control-Allow-Methods": "OPTIONS,POST"
    }

    # 2. Tratamento de OPTIONS (Preflight)
    if method == 'OPTIONS':
        return {
            "statusCode": 200,
            "headers": headers,
            "body": json.dumps({"mensagem": "OK"})
        }
    
    try:
        if "body" not in event or not event["body"]:
            return _response(400, "Corpo da requisição vazio", headers)

        body = json.loads(event["body"])

        # 3. Validação
        for field in REQUIRED_FIELDS:
            field_alt = field.replace("nome", "name").replace("mensagem", "message")
            if not body.get(field) and not body.get(field_alt):
                return _response(400, f"Campo obrigatório ausente: {field}", headers)

        # 4. Dados para o DynamoDB
        item = {
            "id": str(uuid.uuid4()),
            "nome": body.get("nome") or body.get("name") or "Não informado",
            "email": body.get("email") or "Não informado",
            "telefone": body.get("telefone") or body.get("phone") or "Não informado",
            "assunto": body.get("assunto") or body.get("subject") or "Geral",
            "mensagem": body.get("mensagem") or body.get("message") or "",
            "data_envio": datetime.utcnow().isoformat() + "Z",
        }

        table.put_item(Item=item)

        return _response(200, "Obrigado! O Rotary Club da Guarda recebeu a sua mensagem.", headers)

    except Exception as e:
        print(f"Erro: {str(e)}")
        return _response(500, "Erro interno ao processar a mensagem.", headers)

def _response(status_code, message, headers):
    return {
        "statusCode": status_code,
        "headers": headers,
        "body": json.dumps({
            "status": "sucesso" if status_code == 200 else "erro",
            "mensagem": message
        }),
    }