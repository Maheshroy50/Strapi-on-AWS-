output "alb_dns_name" {
  description = "DNS name of the Load Balancer (Access your app here)"
  value       = aws_lb.main.dns_name
}

output "instance_id" {
  description = "ID of the EC2 instance"
  value       = aws_instance.app.id
}

output "public_ip" {
  description = "Public IP for SSH Access"
  value       = aws_instance.app.public_ip
}

output "database_private_ip" {
  description = "Private IP of Database EC2"
  value       = aws_instance.database.private_ip
}

