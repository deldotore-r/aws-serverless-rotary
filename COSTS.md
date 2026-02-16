# 💰 Cost Estimation (AWS Billing)

This project was designed to operate predominantly within the **AWS Free Tier**. However, for the sake of transparency and governance, below we present the estimated actual costs to maintain this infrastructure outside the free period or after exceeding quotas.

## Estimated Summary (Monthly)
| Service | Component | Cost Type | Value (USD) |
| :--- | :--- | :--- | :--- |
| **Route 53** | Hosted Zone (1 domain) | Fixed | $0.50 |
| **CloudFront** | Data Transfer (e.g.: 5GB) | Variable | ~$0.45 |
| **S3** | Storage and Requests | Variable | ~$0.05 |
| **Others** | API GW, Lambda, DynamoDB, SNS | Variable | < $0.05 |
| **TOTAL** | | **Estimated** | **~$1.05 - $2.00** |

## Technical Notes
1. **DNS Alias**: The use of `Alias` records in Route 53 to point to CloudFront does not generate DNS query costs.
2. **KMS**: To keep costs low, this project uses the AWS-managed key (`aws/s3`) for encryption, avoiding the $1.00/month cost of a custom KMS key.
3. **SSL Certificates**: AWS Certificate Manager (ACM) provides free public certificates for use with CloudFront.