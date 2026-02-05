#!/bin/bash

# Create Swap File (Critical for t3.micro)
dd if=/dev/zero of=/swapfile bs=128M count=16
chmod 600 /swapfile
mkswap /swapfile
swapon /swapfile
echo "/swapfile swap swap defaults 0 0" >> /etc/fstab

# Update and Install Docker
yum update -y
yum install -y docker
service docker start
usermod -a -G docker ec2-user

# Install Docker Compose (Optional, but useful if we stick to compose format)
curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose

# Create Directory
mkdir -p /opt/strapi
cd /opt/strapi

# Create docker-compose.yml dynamically
cat <<EOF > docker-compose.yml
services:
  strapi:
    image: ${docker_image}
    container_name: strapi_app
    restart: unless-stopped
    environment:
      DATABASE_CLIENT: postgres
      DATABASE_HOST: postgres
      DATABASE_PORT: 5432
      DATABASE_NAME: strapi
      DATABASE_USERNAME: strapi
      DATABASE_PASSWORD: ${db_password}
      NODE_ENV: production
      HOST: 0.0.0.0
      PORT: 1337
      APP_KEYS: ${app_keys}
      API_TOKEN_SALT: ${api_token_salt}
      ADMIN_JWT_SECRET: ${jwt_secret}
      TRANSFER_TOKEN_SALT: ${transfer_token_salt}
    ports:
      - "1337:1337"
    depends_on:
      postgres:
        condition: service_healthy

  postgres:
    image: postgres:16-alpine
    container_name: strapi_postgres
    environment:
      POSTGRES_USER: strapi
      POSTGRES_PASSWORD: ${db_password}
      POSTGRES_DB: strapi
    volumes:
      - strapi_data:/var/lib/postgresql/data
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U strapi -d strapi"]
      interval: 10s
      timeout: 5s
      retries: 5

volumes:
  strapi_data:
EOF

# Start Application
docker-compose up -d
