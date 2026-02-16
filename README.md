# AWS Serverless Website Architecture (Rotary Club Case Study)

Complete Infrastructure as Code (IaC) for the **Rotary Club da Guarda** portal, migrated from a PaaS platform to a **100% Serverless AWS ecosystem**.

## 🏗️ Architecture
The solution uses a modern, cost-effective approach:
- **Frontend**: S3 (Hosting) + CloudFront (CDN) + ACM (SSL).
- **Backend**: API Gateway + Lambda (Python 3.9) + DynamoDB.
- **DNS**: Route 53 with complex record management (fragmented DKIM).
- **Alerts**: Amazon SNS for immediate email notifications.

## 🔒 Security and Privacy
- **Sensitive Data**: Bucket names, account IDs, and contact emails are managed via variables and protected by `.gitignore`.
- **State Locking**: Uses **Native S3 Locking** (v1.10+) to ensure state integrity without additional resources.
- **IAM**: Restricted policies based on the principle of least privilege.

## 🚀 How to Use
1. Navigate to the `terraform/` folder.
2. Copy the template: `cp terraform.tfvars.example terraform.tfvars`.
3. Fill in the `terraform.tfvars` with your data.
4. Run `terraform init` and `terraform apply`.

## 🛠️ Complementary Documentation
- [DEPLOY_CHECKLIST.md](./DEPLOY_CHECKLIST.md): Flight manual for deploys and maintenance.
- [COSTS.md](./COSTS.md): Detailed breakdown of estimated AWS costs.