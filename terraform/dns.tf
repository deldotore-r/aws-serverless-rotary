###############################################################################
# CONFIGURAÇÃO DE DNS E CERTIFICADO SSL (rotaryclubguarda.org)
###############################################################################

# 1. Zona Hospedada no Route 53
resource "aws_route53_zone" "main" {
  name = "rotaryclubguarda.org"

  tags = {
    Project     = "Rotary Serverless"
    Environment = "prod"
  }
}

# 2. Registros MX (Zoho Mail)
resource "aws_route53_record" "zoho_mx" {
  zone_id = aws_route53_zone.main.zone_id
  name    = "rotaryclubguarda.org"
  type    = "MX"
  ttl     = "3600"
  records = [
    "10 mx.zoho.eu",
    "20 mx2.zoho.eu",
    "50 mx3.zoho.eu"
  ]
}

# 3. Registros TXT Unificados (SPF e Verificação Zoho)
# O Route 53 exige que registros TXT para o mesmo nome sejam agrupados
resource "aws_route53_record" "zoho_txt_combined" {
  zone_id = aws_route53_zone.main.zone_id
  name    = "rotaryclubguarda.org"
  type    = "TXT"
  ttl     = "3600"
  records = [
    "v=spf1 include:zoho.eu ~all",
    "zoho-verification=zb77993928.zmverify.zoho.eu"
  ]
}

# 4. Registro DKIM (Formato compatível com o limite de 255 caracteres)
resource "aws_route53_record" "zoho_dkim" {
  zone_id = aws_route53_zone.main.zone_id
  name    = "netlify._domainkey.rotaryclubguarda.org"
  type    = "TXT"
  ttl     = "3600"
  records = [
    "v=DKIM1; k=rsa; p=MIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQCisQgSiB3DQEBAQUAA4GNADCBiQKBgQD58BtsnVe1uff+iofsxXVcg9V/UbHPqGXBIBGLtZfiAmYhpjcR2pJF\" \"dqBZOaPequMbj7ZFat+Z57cLkSQPN8ACzOC2f1gw/dESVM4huRtDHt4Cj7hU9rRVtz/I6tTwtwvVS27/n18IOSVrpnj8G9Zy0ne23OahMSjozpEeM6MHywIDAQAB"
  ]
}

# 5. Solicitação do Certificado SSL Gratuito (ACM)
resource "aws_acm_certificate" "cert" {
  domain_name       = "rotaryclubguarda.org"
  validation_method = "DNS"

  subject_alternative_names = [
    "www.rotaryclubguarda.org"
  ]

  lifecycle {
    create_before_destroy = true
  }
}

# 6. Registros DNS para Validação Automática do Certificado
resource "aws_route53_record" "cert_validation" {
  for_each = {
    for dvo in aws_acm_certificate.cert.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }

  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  ttl             = 60
  type            = each.value.type
  zone_id         = aws_route53_zone.main.zone_id
}

###############################################################################
# OUTPUTS
###############################################################################

output "name_servers_org" {
  value       = aws_route53_zone.main.name_servers
  description = "Novos Name Servers para configurar no registrador do domínio .org"
}

output "zone_id" {
  value = aws_route53_zone.main.zone_id
}

# Este recurso faz o Terraform esperar a validação real do DNS
resource "aws_acm_certificate_validation" "cert_wait" {
  certificate_arn         = aws_acm_certificate.cert.arn
  validation_record_fqdns = [for record in aws_route53_record.cert_validation : record.fqdn]
}