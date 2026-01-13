## Guia de Manutenção para o Próximo Administrador

### Onde estão os dados?
As mensagens enviadas pelo site não estão em arquivos no servidor, mas sim no **AWS DynamoDB**, na tabela `rotary-form-messages`.

### Como atualizar o site?
1. Altere os arquivos na pasta `/frontend`.
2. Use o comando `aws s3 sync ./frontend s3://[NOME-DO-BUCKET]` para subir as mudanças.

### Como alterar a lógica do formulário?
1. Edite o arquivo `lambda_function/index.py`.
2. Execute `terraform apply` na pasta `/terraform`. O Terraform compactará o novo código e atualizará a AWS automaticamente.