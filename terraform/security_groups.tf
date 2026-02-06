# ALB Security Group (Public)
resource "aws_security_group" "alb" {
  name        = "strapi-alb-sg"
  description = "Allow HTTP inbound traffic"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "HTTP from Internet"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "strapi-alb-sg"
  }
}

# EC2 Security Group (Private)
resource "aws_security_group" "ec2" {
  name        = "strapi-ec2-sg"
  description = "Allow traffic from ALB and SSH"
  vpc_id      = aws_vpc.main.id

  # Allow HTTP (1337) ONLY from ALB
  ingress {
    description     = "Strapi from ALB"
    from_port       = 1337
    to_port         = 1337
    protocol        = "tcp"
    security_groups = [aws_security_group.alb.id]
  }

  # Allow SSH from specific CIDR (Bastion/VPN/Admin IP)
  ingress {
    description = "SSH from Allowed CIDR"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.allowed_ssh_cidr]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "strapi-ec2-sg"
  }
}

# Database Security Group (Private - Only accessible from EC2)
resource "aws_security_group" "database" {
  name        = "strapi-db-sg"
  description = "Allow PostgreSQL from Application EC2 only"
  vpc_id      = aws_vpc.main.id

  # Allow PostgreSQL ONLY from EC2 Security Group
  ingress {
    description     = "PostgreSQL from App EC2"
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [aws_security_group.ec2.id]
  }

  # Allow SSH from EC2 (for debugging via jump)
  ingress {
    description     = "SSH from App EC2"
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = [aws_security_group.ec2.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "strapi-db-sg"
  }
}

