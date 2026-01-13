
# Regiao da AWS onde a infraestrutura sera provisionada.
# Padrao: us-east-1 (Norte da Virginia), geralmente a mais barata.

variable "aws_region" {
  description = "Regiao da AWS"
  type        = "string"
  default     = "us-east-1"
}

# Nome do projeto usado para nomear buckets e tabelas de forma padronizada.

variable "project_name" {
  description = "Nome do projeto para fins de tagging"
  type        = "string"
  default     = "rotary-club-guarda"
}

