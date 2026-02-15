# 💰 Estimativa de Custos (AWS Billing)

Este projeto foi desenhado para operar predominantemente dentro do **AWS Free Tier**. No entanto, para fins de transparência e governança, abaixo apresentamos a estimativa de custos reais para manter esta infraestrutura fora do período gratuito ou após exceder as quotas.

## Resumo Estimado (Mensal)
| Serviço | Componente | Tipo de Custo | Valor (USD) |
| :--- | :--- | :--- | :--- |
| **Route 53** | Hosted Zone (1 domínio) | Fixo | $0.50 |
| **CloudFront** | Transferência de Dados (ex: 5GB) | Variável | ~$0.45 |
| **S3** | Armazenamento e Requests | Variável | ~$0.05 |
| **Outros** | API GW, Lambda, DynamoDB, SNS | Variável | < $0.05 |
| **TOTAL** | | **Estimado** | **~$1.05 - $2.00** |

## Observações Técnicas
1. **DNS Alias**: O uso de registros `Alias` no Route 53 para apontar para o CloudFront não gera custos de consulta DNS.
2. **KMS**: Para manter o custo baixo, este projeto utiliza a chave gerida pela AWS (`aws/s3`) para encriptação, evitando o custo de $1.00/mês de uma chave KMS personalizada.
3. **Certificados SSL**: O AWS Certificate Manager (ACM) oferece certificados públicos gratuitos para uso com CloudFront.