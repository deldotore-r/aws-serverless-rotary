###############################################################################
# Terraform Providers Configuration
#
# Este arquivo define os providers usados pelo Terraform e suas versões.
# Providers são "plugins" que permitem ao Terraform criar e gerenciar
# recursos em provedores de nuvem ou serviços externos.
#
# Neste projeto, usamos exclusivamente a AWS.
###############################################################################

terraform {
  required_version = ">= 1.5.0" # Garante compatibilidade mínima do Terraform

  required_providers {
    aws = {
      source  = "hashicorp/aws" # Provider oficial da HashiCorp para AWS
      version = "~> 5.0"        # Mantém compatibilidade com versões 5.x
    }
  }
}

###############################################################################
# Provider AWS
#
# Configura o provider AWS com região padrão.
# Credenciais são obtidas via:
# - variáveis de ambiente: AWS_ACCESS_KEY_ID / AWS_SECRET_ACCESS_KEY
# - perfil do AWS CLI (~/.aws/credentials)
# - roles atribuídas à máquina (ex: EC2 ou IAM Role)
#
# Isso evita hardcoding de senhas e é prática recomendada.
###############################################################################

provider "aws" {
  region = "us-east-1"
}
