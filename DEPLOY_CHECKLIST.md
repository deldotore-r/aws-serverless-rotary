# 🚀 Deployment & Maintenance Checklist

Este guia serve como referência técnica para garantir a integridade da infraestrutura e o sucesso de novos deploys no ecossistema AWS do Rotary Club da Guarda.

## 1. Pré-requisitos de Ambiente
- [ ] **AWS CLI**: Garantir que o perfil `rotary` está configurado (`aws configure --profile rotary`).
- [ ] **Terraform**: Versão mínima **1.10.x** instalada (obrigatório para *Native S3 Locking*).
- [ ] **Identity**: Validar credenciais antes de começar: `aws sts get-caller-identity --profile rotary`.

## 2. Infraestrutura (Terraform)
- [ ] **Remote State**: Validar no `backend.tf` se o bucket possui `encrypt = true` e `use_lockfile = true`.
- [ ] **DNS Integrity**: 
    - [ ] Verificar se registros TXT/DKIM (Zoho) longos estão fragmentados entre aspas no código HCL.
    - [ ] Validar registros MX para garantir a continuidade do serviço de e-mail.
- [ ] **SSL/ACM**: Garantir que o certificado para uso com CloudFront foi solicitado na região `us-east-1`.

## 3. Backend & Integrações
- [ ] **Lambda**:
    - [ ] Verificar se o pacote `.zip` de payload está sendo gerado via `archive_file`.
    - [ ] Validar variáveis de ambiente no `lambda.tf`: `TABLE_NAME` e `SNS_TOPIC_ARN`.
- [ ] **Permissões (IAM)**: Garantir políticas restritas de `dynamodb:PutItem` e `sns:Publish`.
- [ ] **SNS (Alerta)**: Após o deploy inicial, verificar a caixa de entrada do e-mail configurado e confirmar a subscrição (*Opt-in*).

## 4. Frontend & Distribuição
- [ ] **CORS**: Validar se o domínio final (`rotaryclubguarda.org`) está na lista de origens permitidas no API Gateway.
- [ ] **API Endpoint**: Certificar que o ficheiro `frontend/js/script.js` aponta para a URL real gerada pelo output do Terraform.
- [ ] **CloudFront**: Executar invalidação de cache (`/*`) via CLI ou console após atualizações no S3.

## 5. Qualidade e Segurança
- [ ] Executar `terraform fmt` e `terraform validate` antes de qualquer `plan`.
- [ ] **Segurança de Dados**: Validar se o ficheiro `terraform.tfvars` **não** está sendo rastreado pelo Git (`git check-ignore`).
- [ ] **State Lock**: Confirmar que o arquivo `.tflock` é criado no S3 durante a execução do `apply`.