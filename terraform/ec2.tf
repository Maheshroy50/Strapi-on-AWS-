# Get latest Amazon Linux 2023 AMI
data "aws_ami" "amazon_linux_2023" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-2023.*-x86_64"]
  }
}


# EC2 Instance
resource "aws_instance" "app" {
  ami                         = data.aws_ami.amazon_linux_2023.id
  instance_type               = var.instance_type
  subnet_id                   = aws_subnet.public[0].id # Moved to Public to allow SSH
  associate_public_ip_address = true

  vpc_security_group_ids = [aws_security_group.ec2.id]
  key_name               = aws_key_pair.deployer.key_name

  # Template User Data to inject variables
  user_data = templatefile("${path.module}/user_data.sh", {
    docker_image        = var.docker_image
    db_host             = aws_instance.database.private_ip
    db_password         = var.db_password
    jwt_secret          = var.jwt_secret
    api_token_salt      = var.api_token_salt
    transfer_token_salt = var.transfer_token_salt
    app_keys            = var.app_keys
  })

  tags = {
    Name = "strapi-server"
  }
}

# Attach instance to Target Group
resource "aws_lb_target_group_attachment" "main" {
  target_group_arn = aws_lb_target_group.main.arn
  target_id        = aws_instance.app.id
  port             = 1337
}
