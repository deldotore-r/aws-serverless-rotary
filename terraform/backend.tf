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
# e state lock habilitados.
#
# O arquivo de estado (.tfstate) é movido da sua máquina local para a nuvem.
# Isso garante que a infraestrutura possa ser gerenciada de forma segura e 
# evita perda de dados.
###############################################################################

terraform {
  backend "s3" {
    profile      = "rotary"
    bucket       = "rotary-guarda-terraform-state"
    key          = "serverless/terraform.tfstate"
    region       = "us-east-1"
    encrypt      = true
    use_lockfile = true
  }
}
