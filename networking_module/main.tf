provider "aws" {
  region = "us-east-1"
}

resource "aws_vpc" "myvpc" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true
  tags = {
    Name = var.vpc_name
  }
}

resource "aws_subnet" "public_subnets_alb" {
  count                  = 2
  vpc_id                 = aws_vpc.myvpc.id
  cidr_block             = var.public_subnets[count.index]
  availability_zone      = var.azs[count.index]
  map_public_ip_on_launch = true
  tags = {
    Name = "public_subnet_${count.index + 1}"
  }
}

resource "aws_subnet" "private_subnets_alb" {
  count                  = 2
  vpc_id                 = aws_vpc.myvpc.id
  cidr_block             = var.private_subnets[count.index]
  availability_zone      = var.azs[count.index]
  map_public_ip_on_launch = true
  tags = {
    Name = "private_subnet_${count.index + 1}"
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.myvpc.id
  tags = {
    Name = var.igw_name
  }
}

resource "aws_route_table" "route_table" {
  vpc_id = aws_vpc.myvpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
  tags = {
    Name = var.route_table_name
  }
}

resource "aws_route_table_association" "route_table_assoc" {
  count          = length(aws_subnet.public_subnets_alb)
  subnet_id      = aws_subnet.public_subnets_alb[count.index].id
  route_table_id = aws_route_table.route_table.id
}

resource "aws_security_group" "alb_sg" {
  
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
    Name = var.sg_name
  }
}




