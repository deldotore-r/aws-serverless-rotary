###############################################################################
# Terraform Remote State Configuration
#
# Este arquivo configura o armazenamento do estado do Terraform em um backend
# remoto no Amazon S3.
#
# O uso de estado remoto é fundamental para:
# - Evitar perda do arquivo terraform.tfstate
# - Permitir reconstrução da infraestrutura a partir de qualquer máquina
# - Manter consistência entre múltiplas execuções do Terraform
#
# Neste projeto, o estado é armazenado em um bucket S3 dedicado, com criptografia
# habilitada.
###############################################################################
###############################################################################
# Configuração do Backend Remoto (S3)
#
# O arquivo de estado (.tfstate) é movido da sua máquina local para a nuvem.
# Isso garante que a infraestrutura possa ser gerenciada de forma segura e 
# evita perda de dados caso seu notebook tenha problemas.
###############################################################################

terraform {
  backend "s3" {
    # Perfil da AWS CLI configurado localmente. 
    # CRÍTICO: Garante que o Terraform use as credenciais 'rotary' para acessar o bucket.
    profile = "rotary"

    # Bucket S3 previamente criado exclusivamente para armazenar o estado
    # do Terraform. Este bucket NÃO armazena dados da aplicação.
    bucket = "rotary-guarda-terraform-state"

    # Caminho (key) dentro do bucket onde o arquivo terraform.tfstate será salvo.
    # Usar um prefixo (serverless/) evita conflitos caso outros projetos utilizem
    # o mesmo bucket no futuro.
    key = "serverless/terraform.tfstate"

    # Região AWS onde o bucket S3 está localizado.
    # Deve corresponder exatamente à região do bucket.
    region = "us-east-1"

    # Habilita criptografia do estado em repouso no S3.
    # Recomendado para proteção de dados sensíveis contidos no estado.
    encrypt = true

    # Observação sobre locking:
    # Para este projeto (uso individual), o mecanismo de consistência forte 
    # do S3 em us-east-1 é suficiente para evitar corrupção do estado.
    #
    # Se o projeto crescer para uma equipe, recomenda-se adicionar:
    # dynamodb_table = "terraform-state-lock-table"
  }
}
