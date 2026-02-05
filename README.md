# Strapi AWS Automation Project

This project contains a **Strapi v5** CMS application configured for:
1.  **Local Development** using Docker Compose.
2.  **Automated Building** using GitHub Actions (CI/CD).
3.  **AWS Deployment** using Terraform.

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

This provisions a **VPC**, **Public/Private Subnets**, **Client VPN / Bastion** (Simulated via SG), **ALB**, and an **EC2 Instance**.

### 1. Prerequisites
*   [Terraform Installed](https://developer.hashicorp.com/terraform/downloads)
*   **SSH Key Pair**: Generate a key for EC2 access inside the `terraform/` folder.
    ```bash
    cd terraform
    ssh-keygen -f strapi-key
    # Press Enter (empty passphrase)
    ```

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
# Initialize Terraform
terraform init

# Preview Changes
terraform plan

# Apply Changes (Type 'yes' to confirm)
terraform apply
```

### 4. Verify & Access
*   **URL**: Terraform will output the `alb_dns_name` 
*   **Wait**: It takes ~5 minutes for the EC2 to launch, run User Data, install Docker, pull the image, and start Strapi.
*   **Visit**: Open the ALB URL in your browser to see the Strapi Welcome/Admin page.

---


