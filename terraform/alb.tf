# Application Load Balancer
resource "aws_lb" "main" {
  name               = "strapi-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb.id]
  subnets            = aws_subnet.public[*].id

  tags = {
    Name = "strapi-alb"
  }
}

# Target Group
resource "aws_lb_target_group" "main" {
  name        = "strapi-tg"
  port        = 1337 # Strapi Port
  protocol    = "HTTP"
  vpc_id      = aws_vpc.main.id
  target_type = "instance"

  health_check {
    path                = "/" # Check root (lighter than admin)
    interval            = 60  # Wait longer between checks
    timeout             = 10
    healthy_threshold   = 2
    unhealthy_threshold = 5   # Allow more failures during startup
    matcher             = "200-404" # Accept 200, 302, 404 (Strapi root often 404s or redirects)
  }
}

# Listener (HTTP -> Forward)
resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.main.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.main.arn
  }
}
