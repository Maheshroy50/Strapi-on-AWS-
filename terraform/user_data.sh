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

# Wait for database to be ready
sleep 30

# Run Strapi Container (connects to Database in Private Subnet)
docker run -d \
  --name strapi_app \
  --restart unless-stopped \
  -e DATABASE_CLIENT=postgres \
  -e DATABASE_HOST=${db_host} \
  -e DATABASE_PORT=5432 \
  -e DATABASE_NAME=strapi \
  -e DATABASE_USERNAME=strapi \
  -e DATABASE_PASSWORD=${db_password} \
  -e NODE_ENV=production \
  -e HOST=0.0.0.0 \
  -e PORT=1337 \
  -e APP_KEYS=${app_keys} \
  -e API_TOKEN_SALT=${api_token_salt} \
  -e ADMIN_JWT_SECRET=${jwt_secret} \
  -e JWT_SECRET=${jwt_secret} \
  -e TRANSFER_TOKEN_SALT=${transfer_token_salt} \
  -p 1337:1337 \
  ${docker_image}
