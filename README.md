# Strapi AWS Automation Project

This project contains a **Strapi v5** CMS application configured for:
1.  **Local Development** using Docker Compose.
2.  **Automated Building** using GitHub Actions (CI/CD).
3.  **AWS Deployment** using Terraform.

---

## 📐 AWS Architecture

For detailed architecture documentation with diagrams, see:
**[AWS Architecture Documentation](./AWS_Architecture.md)**

### Architecture Overview:
- **Application (Strapi)** → Public Subnet (accessible via ALB)
- **Database (PostgreSQL)** → Private Subnet (isolated, no public access)
- **Load Balancer (ALB)** → Routes traffic to Strapi
- **NAT Gateway** → Allows private subnet to access internet

---

## 🛠 Local Development

To run the project locally without pushing:

1.  **Start Docker**:
    ```bash
    docker-compose up --build
    ```
2.  **Access Admin Panel**: [http://localhost:1337/admin](http://localhost:1337/admin)

---

## 🚀 CI/CD Setup (GitHub Actions)

To enable the automated Docker build pipeline (required for deployment to `t3.micro`), follow these steps:

### 1. Create a GitHub Repository
Push this code to a new GitHub repository (`master/main` branch).

### 2. Configure Secrets (Crucial)
In your GitHub Repo > **Settings** > **Secrets and variables** > **Actions**, add:
*   `DOCKER_USERNAME`: Your Docker Hub username 
*   `DOCKER_PASSWORD`: Your Docker Hub Access Token.

### 3. Trigger Build
Pushing to `main` will trigger the **"Build and Push Docker Image"** workflow.
*   **Result**: An image `maheshbhoopathirao/my-strapi-project:latest` will be pushed to Docker Hub.

---

## ☁️ AWS Deployment (Terraform)

This provisions a **VPC**, **Public/Private Subnets**, **NAT Gateway**, **ALB**, and **EC2 Instances** (Strapi + Database).

### 1. Prerequisites
*   [Terraform Installed](https://developer.hashicorp.com/terraform/downloads)
*   AWS CLI configured with credentials

> **Note:** SSH keys are now **automatically generated** by Terraform. No manual `ssh-keygen` required!

### 2. Configure Variables
Ensure `terraform/terraform.tfvars` exists with your secrets:

```hcl
docker_image        = "maheshbhoopathirao/my-strapi-project:latest"
db_password         = "change_me_securely"
jwt_secret          = "random_string_here"
api_token_salt      = "random_string_here"
transfer_token_salt = "random_string_here"
app_keys            = "key1,key2"
allowed_ssh_cidr    = "0.0.0.0/0" # Update to your IP for security
```

### 3. Deploy
Run the following commands from the `terraform/` directory:

```bash
# Initialize Terraform (downloads required providers)
terraform init

# Preview Changes
terraform plan

# Apply Changes (Type 'yes' to confirm)
terraform apply
```

### 4. Access SSH
After deployment, Terraform creates `terraform/strapi-key.pem` automatically:

```bash
# Connect to Strapi EC2
ssh -i terraform/strapi-key.pem ec2-user@$(terraform output -raw public_ip)

# Connect to Database EC2 (via Strapi as jump host)
ssh -J ec2-user@$(terraform output -raw public_ip) ec2-user@$(terraform output -raw database_private_ip)
```

### 5. Verify & Access
*   **URL**: Terraform will output the `alb_dns_name` 
*   **Wait**: It takes ~5 minutes for the EC2 to launch, run User Data, install Docker, pull the image, and start Strapi.
*   **Visit**: Open the ALB URL in your browser to see the Strapi Welcome/Admin page.

---

## 🗂 Project Structure

```
├── my-strapi-project/          # Strapi Application
│   ├── config/                 # Database, Server, Plugins config
│   ├── Dockerfile              # Container build instructions
│   └── package.json
├── terraform/                  # Infrastructure as Code
│   ├── vpc.tf                  # Networking
│   ├── security_groups.tf      # Firewall rules
│   ├── ec2.tf                  # Strapi Application EC2
│   ├── database.tf             # PostgreSQL Database EC2
│   ├── alb.tf                  # Load Balancer
│   ├── key_pair.tf             # Auto-generated SSH keys
│   └── user_data.sh            # Startup script
├── .github/workflows/          # CI/CD Pipeline
│   └── docker-publish.yml      # Build & Push Docker image
├── AWS_Architecture.md         # Architecture Documentation
└── README.md                   # This file
```

---

## 🔐 Security Notes

- Database EC2 has **no public IP** (Private Subnet)
- Database only accepts connections from Strapi EC2
- SSH access restricted to specified CIDR
- ALB handles public traffic on port 80

---
