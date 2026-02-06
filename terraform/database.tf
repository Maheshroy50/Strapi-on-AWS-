# Database EC2 Instance (Private Subnet)
resource "aws_instance" "database" {
  ami           = data.aws_ami.amazon_linux_2023.id
  instance_type = "t3.micro"
  subnet_id     = aws_subnet.private.id # Private Subnet - No public IP

  vpc_security_group_ids = [aws_security_group.database.id]
  key_name               = aws_key_pair.deployer.key_name

  user_data = <<-EOF
    #!/bin/bash
    
    # Create Swap File
    dd if=/dev/zero of=/swapfile bs=128M count=16
    chmod 600 /swapfile
    mkswap /swapfile
    swapon /swapfile
    echo "/swapfile swap swap defaults 0 0" >> /etc/fstab

    # Install Docker
    yum update -y
    yum install -y docker
    service docker start
    usermod -a -G docker ec2-user

    # Run PostgreSQL Container
    docker run -d \
      --name strapi_postgres \
      --restart unless-stopped \
      -e POSTGRES_USER=strapi \
      -e POSTGRES_PASSWORD=${var.db_password} \
      -e POSTGRES_DB=strapi \
      -p 5432:5432 \
      -v postgres_data:/var/lib/postgresql/data \
      postgres:16-alpine
  EOF

  tags = {
    Name = "strapi-database"
  }
}
