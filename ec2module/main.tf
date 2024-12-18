variable "ami_value" {
  type = string
}
variable "ec2_instance_type" {
  type = string
}
variable "security_grps" {
  type = string
}
variable "public_subnets" {
  type = list(string)
}

resource "aws_instance" "myalb_ec2_1" {
  ami           = var.ami_value # Amazon Linux 2 AMI (update as per region)
  count = length(var.public_subnets)
  instance_type = var.ec2_instance_type
  subnet_id     = var.public_subnets[count.index]
  security_groups = [
    var.security_grps
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
  count = length(var.public_subnets)
  ami           = "ami-0c02fb55956c7d316" # Amazon Linux 2 AMI (update as per region)
  instance_type = "t2.micro"
  subnet_id     = var.public_subnets[count.index]
  security_groups = [
    var.security_grps
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

output "instance_id1" {
  value = aws_instance.myalb_ec2_1[0].id
}

output "instance_id2" {
  value = aws_instance.myalb_ec2_2[1].id
}