import json
import boto3
import uuid
import os
from datetime import datetime

###############################################################################
# Configuração inicial
###############################################################################

# Inicializa o cliente DynamoDB
dynamodb = boto3.resource("dynamodb")

# Nome da tabela, vindo da variável de ambiente definida no Terraform
# Permite trocar o nome da tabela sem alterar o código Python
TABLE_NAME = os.environ.get("TABLE_NAME", "rotary-form-messages")
table = dynamodb.Table(TABLE_NAME)

# Lista de campos obrigatórios que devem ser enviados pelo formulário
REQUIRED_FIELDS = ["nome", "email", "mensagem"]

###############################################################################
# Função Lambda principal
# Esta função será executada sempre que a API Gateway receber uma requisição POST
###############################################################################
def lambda_handler(event, context):
    """
    Função principal executada pela AWS Lambda para processar o formulário de contato
    """
    try:
        # 1. Verifica se a requisição possui corpo
        if "body" not in event:
            return _response(400, "Requisição inválida: corpo vazio")

        # 2. Converte o corpo JSON em um dicionário Python
        body = json.loads(event["body"])

        # 3. Validação mínima: garante que campos obrigatórios existam
        for field in REQUIRED_FIELDS:
            # Verifica possíveis alternativas de nomes do campo (ex: 'nome' ou 'name')
            if not body.get(field) and not body.get(field.replace("nome", "name")):
                return _response(400, f"Campo obrigatório ausente: {field}")

        # 4. Montagem do item a ser salvo no DynamoDB
        # Cada mensagem recebe um 'id' único gerado via UUID
        # As datas são armazenadas em formato ISO UTC, padrão para bancos NoSQL
        item = {
            "id": str(uuid.uuid4()),
            "nome": body.get("nome") or body.get("name") or "Não informado",
            "email": body.get("email") or "Não informado",
            "telefone": body.get("telefone") or body.get("phone") or "Não informado",
            "assunto": body.get("assunto") or body.get("subject") or "Geral",
            "mensagem": body.get("mensagem") or body.get("message") or "",
            "data_envio": datetime.utcnow().isoformat() + "Z",
        }

        # 5. Persistência no DynamoDB
        # put_item insere ou sobrescreve um item baseado na chave primária ('id')
        table.put_item(Item=item)

        # 6. Retorno de sucesso para o frontend
        # Inclui cabeçalhos CORS para permitir que o site no S3 acesse a API
        return _response(200, "Obrigado! O Rotary Club da Guarda recebeu a sua mensagem.")

    except Exception as e:
        # Registro do erro detalhado no CloudWatch
        # Útil para auditoria e depuração
        print(f"Erro detectado: {str(e)}")

        # Retorno genérico de erro para o frontend
        return _response(500, "Falha interna ao processar mensagem.")

###############################################################################
# Função auxiliar para montar respostas HTTP padronizadas
###############################################################################
def _response(status_code, message):
    """
    Retorna um dicionário no formato que API Gateway espera:
    - statusCode: código HTTP
    - headers: CORS e tipo de conteúdo
    - body: mensagem em JSON
    """
    return {
        "statusCode": status_code,
        "headers": {
            "Access-Control-Allow-Origin": "*",  # Para produção, usar domínio específico
            "Content-Type": "application/json",
        },
        "body": json.dumps({
            "status": "sucesso" if status_code == 200 else "erro",
            "mensagem": message
        }),
    }
