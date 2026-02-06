# SSH Key Pair Generation using Terraform TLS Provider
# This eliminates the need to manually run ssh-keygen

# Generate RSA Private Key
resource "tls_private_key" "ssh_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

# Create AWS Key Pair from generated public key
resource "aws_key_pair" "deployer" {
  key_name   = "strapi-deploy-key"
  public_key = tls_private_key.ssh_key.public_key_openssh

  tags = {
    Name = "strapi-deploy-key"
  }
}

# Save private key locally for SSH access
resource "local_file" "private_key" {
  content         = tls_private_key.ssh_key.private_key_pem
  filename        = "${path.module}/strapi-key.pem"
  file_permission = "0400"
}

# Output the private key path for reference
output "ssh_private_key_path" {
  description = "Path to the SSH private key file"
  value       = local_file.private_key.filename
}
