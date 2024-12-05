provider "aws" {
  region = "us-east-1"
}

resource "aws_vpc" "myvpc" {
  cidr_block = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support = true
  tags = {
    Name = "my_terraform_vpc"
  }
}

resource "aws_subnet" "mypublicsubnet1" {
  vpc_id = aws_vpc.myvpc.id
  cidr_block = "10.0.1.0/24"
  availability_zone = "us-east-1a"
  map_public_ip_on_launch = true
  tags = {
    Name = "public_subnet1"
  }
}

resource "aws_subnet" "mypublicsubnet2" {
  vpc_id = aws_vpc.myvpc.id
  cidr_block = "10.0.2.0/24"
  availability_zone = "us-east-1b"
  map_public_ip_on_launch = true
  tags = {
    Name = "public_subnet2"
  }
}

resource "aws_subnet" "myprivatesubnet" {
  vpc_id = aws_vpc.myvpc.id
  cidr_block = "10.0.3.0/24"
  availability_zone = "us-east-1c"
  tags = {
    Name = "private_subnet"
  }
}

# Create an Internet Gateway
resource "aws_internet_gateway" "my_igw" {
  vpc_id = aws_vpc.myvpc.id
  tags = {
    Name = "MyIGW"
  }
}

# Create a Route Table
resource "aws_route_table" "my_route_table" {
  vpc_id = aws_vpc.myvpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.my_igw.id
  }

  tags = {
    Name = "MyRouteTable"
  }
}

# Associate the Route Table with the Subnet
resource "aws_route_table_association" "my_route_table_assoc1" {
  subnet_id      = aws_subnet.mypublicsubnet1.id
  route_table_id = aws_route_table.my_route_table.id
}

resource "aws_route_table_association" "my_route_table_assoc2" {
  subnet_id      = aws_subnet.mypublicsubnet2.id
  route_table_id = aws_route_table.my_route_table.id
}


resource "aws_instance" "myalb_ec2_1" {
  ami           = "ami-0c02fb55956c7d316" # Amazon Linux 2 AMI (update as per region)
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.mypublicsubnet2.id
  security_groups = [
    aws_security_group.alb_sg.id
  ]
  associate_public_ip_address = true
  tags = {
    Name = "ec2_Instance1"
  }

  user_data = <<-EOF
              #!/bin/bash
              sudo yum update -y
              sudo yum install -y httpd
              sudo systemctl start httpd
              sudo systemctl enable httpd
              echo "Hello from the AZ1" > /var/www/html/index.html
              EOF
}


resource "aws_instance" "myalb_ec2_2" {
  ami           = "ami-0c02fb55956c7d316" # Amazon Linux 2 AMI (update as per region)
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.mypublicsubnet1.id
  security_groups = [
    aws_security_group.alb_sg.id
  ]
  associate_public_ip_address = true

  tags = {
    Name = "ec2_Instance2"
  }

  user_data = <<-EOF
              #!/bin/bash
              sudo yum update -y
              sudo yum install -y httpd
              sudo systemctl start httpd
              sudo systemctl enable httpd
              echo "Hello from the AZ2!" > /var/www/html/index.html
              EOF
}

# Security Group for ALB
resource "aws_security_group" "alb_sg" {
  name        = "ALB-SG"
  description = "Allow HTTP and HTTPS traffic"
  vpc_id      = aws_vpc.myvpc.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
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
    Name = "ALB-SG"
  }
}

# Create an ALB
resource "aws_lb" "my_alb" {
  name               = "my-application-lb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_sg.id]
  subnets            = [aws_subnet.mypublicsubnet1.id, aws_subnet.mypublicsubnet2.id]

  tags = {
    Name = "MyALB"
  }
}


# Create a Target Group
resource "aws_lb_target_group" "my_target_group" {
  name     = "my-target-group"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.myvpc.id

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
  target_id = aws_instance.myalb_ec2_1.id
  port = 80
}

resource "aws_lb_target_group_attachment" "tga_2" {
  target_group_arn = aws_lb_target_group.my_target_group.arn
  target_id = aws_instance.myalb_ec2_2.id
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



output "myalb_ec2_1_public_ip" {
  value = aws_instance.myalb_ec2_1.public_ip
}

output "myalb_ec2_2_public_ip" {
  value = aws_instance.myalb_ec2_2.public_ip
}

output "myalb_dns_name" {
  value = aws_lb.my_alb.dns_name
}
 
output "vpc_id" {
    value = aws_vpc.myvpc.id
} 