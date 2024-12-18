
resource "aws_lb" "my_alb" {
  //count = length(var.public_subnets)
  name               = var.alb_name
  internal           = false
  load_balancer_type = "application"
  security_groups    =  [var.security_alb] 
  subnets            = [var.public_subnets[0], var.public_subnets[1]]
  tags = {
    Name = "MyALB"
  }
}


# Create a Target Group
resource "aws_lb_target_group" "my_target_group" {
  name     = "my-target-group"
  port     = 80
  protocol = "HTTP"
  vpc_id   = var.vpcid

  health_check {
    path                = "/"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 3
    unhealthy_threshold = 2
    matcher             = "200"
  }

  tags = {
    Name = "MyTargetGroup"
  }
}

resource "aws_lb_target_group_attachment" "tga_1" {
  target_group_arn = aws_lb_target_group.my_target_group.arn
  target_id = var.instance_id1
  port = 80
}

resource "aws_lb_target_group_attachment" "tga_2" {
  target_group_arn = aws_lb_target_group.my_target_group.arn
  target_id = var.instance_id2
  port = 80
}

# Create a Listener
resource "aws_lb_listener" "http_listener" {
  load_balancer_arn = aws_lb.my_alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.my_target_group.arn
  }
}

