# 🏛️ Rotary Club da Guarda
### Site Estático + Formulário Serverless na AWS

Este projeto implementa uma solução moderna e escalável para o **Rotary Club da Guarda**, utilizando uma arquitetura 100% serverless. O site é hospedado no **AWS S3** e conta com um formulário de contato integrado via **API Gateway**, processado por uma função **Lambda** e armazenado no **DynamoDB**.

Toda a infraestrutura é gerenciada como código (**IaC**) através do **Terraform**, garantindo deploys rápidos, seguros e totalmente reprodutíveis.

---

## 🏗️ Estrutura do Projeto

A organização dos arquivos segue as melhores práticas de modularização:

```text
.
├── 📂 bootstrap/                # Infraestrutura inicial (S3 Bucket para State Remoto)
│   └── main.tf
├── 📂 frontend/                  # Assets do site estático
│   ├── index.html                # Página principal
│   ├── contato.html              # Formulário de contato
│   ├── 📂 css/                   # Estilização
│   ├── 📂 js/                    # Lógica de envio (Fetch API)
│   └── 📂 imagens/               # Recursos visuais
├── 📂 terraform/                 # Core da infraestrutura
│   ├── api_gateway.tf            # Configuração do endpoint HTTP
│   ├── dynamodb.tf               # Definição da tabela de mensagens
│   ├── lambda.tf                 # Configuração da função e permissões IAM
│   ├── s3_website.tf             # Bucket configurado para Static Website Hosting
│   ├── 📂 lambda/                # Código-fonte da função (Python 3.9)
│   │   └── contact_form_handler  # Diretório do handler da função Lambda
             └── index.py         # Script principal de processamento
│   ├── providers.tf              # Definição dos provedores AWS
│   ├── variables.tf              # Variáveis de ambiente
│   └── outputs.tf                # Informações geradas após o deploy
└── README.md                     # Documentação do projeto
```

---

## ⚙️ Stack Tecnológica

| Serviço | Função no Projeto |
| :--- | :--- |
| **AWS S3** | Hospedagem de alta performance para o frontend estático. |
| **API Gateway** | Interface HTTP para recepção segura de dados do formulário. |
| **AWS Lambda** | Processamento lógico e validação de dados em Python. |
| **DynamoDB** | Banco de dados NoSQL para armazenamento persistente. |
| **Terraform** | Orquestração completa da infraestrutura como código. |

---

## 🛠️ Arquitetura e Fluxo de Dados

O fluxo de comunicação entre os serviços foi desenhado para ser resiliente e de baixa latência:

1.  **Interação**: O usuário preenche o formulário no site (S3).
2.  **Requisição**: O frontend realiza um `POST` para o endpoint da **API Gateway**.
3.  **Processamento**: A **Lambda** valida os campos, gera um `UUID` e registra o timestamp.
4.  **Persistência**: Os dados são gravados na tabela do **DynamoDB**.
5.  **Feedback**: O sistema retorna um JSON de sucesso/erro para o usuário final.

> [!TIP]
> **Diagrama de Fluxo**:
> `Usuário` ➔ `S3 (Frontend)` ➔ `API Gateway` ➔ `Lambda` ➔ `DynamoDB`

---

## ⚡ Guia de Execução

### 1. Preparação do Ambiente (Bootstrap)
Antes de tudo, configure o bucket que armazenará o estado do Terraform para evitar conflitos:
```bash
cd bootstrap
terraform init
terraform apply -auto-approve
```

### 2. Provisionamento da Infraestrutura
Com o backend configurado, suba os serviços da aplicação:
```bash
cd ../terraform
terraform init
terraform plan
terraform apply -auto-approve
```

### 3. Deploy do Frontend
Após o provisionamento, faça o upload dos arquivos para o bucket S3:
```bash
aws s3 sync ../frontend/ s3://$(terraform output -raw website_bucket_name) --acl public-read
```

---

## 🔐 Segurança e Boas Práticas

*   **Estado Remoto**: Protegido com versionamento, *Object Lock* e criptografia **AES256**.
*   **Princípio do Menor Privilégio**: A Lambda possui permissões restritas apenas para escrita no DynamoDB e logs no CloudWatch.
*   **CORS**: Configurado para aceitar requisições apenas da origem controlada.
*   **Custo Zero**: Arquitetura otimizada para o *Free Tier* da AWS.

---

## 📋 Outputs Principais

Ao final do deploy, o Terraform fornecerá:
*   **URL do Site**: Link público para acessar o portal.
*   **Endpoint API**: Endereço para integração do formulário.
*   **Recursos**: Nomes exatos da Lambda e Tabela para monitoramento.

---
**Desenvolvido para:** *Rotary Club da Guarda*  
**Tecnologias:** `AWS` | `Terraform` | `Python` | `Serverless`
