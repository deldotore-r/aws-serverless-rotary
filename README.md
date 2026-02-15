# AWS Serverless Website Architecture (Rotary Club Case Study)

Infraestrutura completa como código (IaC) para o portal do **Rotary Club da Guarda**, migrado de uma plataforma PaaS para um ecossistema **100% Serverless na AWS**.

## 🏗️ Arquitetura
A solução utiliza uma abordagem moderna e de baixo custo:
- **Frontend**: S3 (Hosting) + CloudFront (CDN) + ACM (SSL).
- **Backend**: API Gateway + Lambda (Python 3.9) + DynamoDB.
- **DNS**: Route 53 com gestão de registos complexos (DKIM fragmentado).
- **Alertas**: Amazon SNS para notificações imediatas por e-mail.



## 🔒 Segurança e Privacidade
- **Dados Sensíveis**: Nomes de buckets, IDs de contas e e-mails de contacto são geridos via variáveis e protegidos pelo `.gitignore`.
- **State Locking**: Utilização de **Native S3 Locking** (v1.10+) para garantir a integridade do estado sem recursos adicionais.
- **IAM**: Políticas restritas baseadas no princípio do menor privilégio.

## 🚀 Como Utilizar
1. Navegue até a pasta `terraform/`.
2. Copie o modelo: `cp terraform.tfvars.example terraform.tfvars`.
3. Preencha o `terraform.tfvars` com os seus dados.
4. Execute `terraform init` e `terraform apply`.

## 🛠️ Documentação Complementar
- [DEPLOY_CHECKLIST.md](./DEPLOY_CHECKLIST.md): Manual de voo para deploys e manutenção.
- [COSTS.md](./COSTS.md): Detalhamento de custos estimados na AWS.