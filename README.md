# README em desenvolvimento!

---
---

# Rotary Club da Guarda – Site Estático + Formulário Serverless

Este projeto implementa um **site estático hospedado no AWS S3**, integrado com um **formulário de contato processado por Lambda** e armazenado em **DynamoDB**.  
Tudo orquestrado via **Terraform**, garantindo infraestrutura como código (IaC) e deploy reproduzível.

---

## 🏗 Estrutura do Projeto

.
├── bootstrap/ # Infraestrutura inicial do Terraform (bucket de estado remoto)
│ └── main.tf
├── frontend/ # Arquivos do site estático
│ ├── contato.html
│ ├── css/
│ ├── imagens/
│ ├── index.html
│ ├── js/
│ └── outras páginas HTML
├── terraform/ # Código Terraform principal
│ ├── api_gateway.tf # Criação da API Gateway
│ ├── backend.tf # Configuração do estado remoto
│ ├── dynamodb.tf # Tabela DynamoDB para armazenar mensagens
│ ├── lambda/ # Código da Lambda
│ │ └── contact_form_handler/index.py
│ ├── lambda.tf # Configuração da Lambda
│ ├── outputs.tf # Outputs do Terraform
│ ├── providers.tf # Configuração de providers AWS
│ ├── s3_website.tf # Bucket S3 para o site estático
│ └── variables.tf # Variáveis Terraform
└── README.md


---

## ⚙ Tecnologias e Serviços AWS

- **S3** – Hospedagem de site estático com leitura pública.  
- **API Gateway (HTTP)** – Recebe as requisições do formulário.  
- **AWS Lambda (Python 3.9)** – Processa e valida os dados enviados.  
- **DynamoDB** – Armazena as mensagens do formulário com alta disponibilidade e escalabilidade.  
- **Terraform** – Provisiona toda a infraestrutura de forma reprodutível.

---

## 🛠 Arquitetura do fluxo

1. Usuário preenche o **formulário** no site estático hospedado no S3.  
2. O **frontend** envia os dados para a **API Gateway** (método POST).  
3. A **Lambda** recebe os dados, valida, adiciona `id` e `data_envio`, e grava no **DynamoDB**.  
4. Lambda retorna uma resposta JSON ao frontend, confirmando envio ou erro.  

> **Diagrama simplificado**:
>
> ```
> [Usuário] --> [S3 Frontend] --> [API Gateway] --> [Lambda] --> [DynamoDB]
> ```

---

## ⚡ Como rodar o projeto

### 1. Bootstrap do Terraform
```bash
cd bootstrap
terraform init
terraform apply

Isso cria o bucket S3 que armazenará o estado remoto (terraform.tfstate) com versionamento, criptografia e Object Lock habilitados.

2. Terraform principal

cd ../terraform
terraform init
terraform plan
terraform apply

Provisiona todo o restante: Lambda, API Gateway, DynamoDB e bucket do site estático.

3. Deploy do frontend

Copie todo o conteúdo da pasta frontend para o bucket S3 criado (aws_s3_bucket.website_bucket).

Certifique-se que os arquivos estão públicos ou que a política do bucket permite leitura.

Outputs importantes do Terraform

Após o apply, você terá:

URL do site S3 → acessar o site no navegador.

Endpoint API Gateway → URL para envio do formulário.

Nome da função Lambda → para depuração ou logs no CloudWatch.

Nome da tabela DynamoDB → onde as mensagens ficam armazenadas.

Segurança

Estado remoto protegido com versionamento, Object Lock e criptografia AES256.

Lambda segue princípio do menor privilégio: só pode escrever na tabela do DynamoDB e criar logs no CloudWatch.

CORS configurado apenas para o site (em produção, restringir ao domínio real).

Considerações finais

Projeto totalmente serverless, com custo praticamente zero em ambientes de teste.

Estrutura modular: fácil adicionar novas páginas, tabelas ou integrações futuras.

Código comentado e didático, pronto para transição entre ambientes (Windows, WSL ou Linux).

Desenvolvido para: Rotary Club da Guarda
Tecnologias: AWS, Terraform, Python, HTML/CSS/JS