variable "engine_name" {
  type = string
}
variable "engine_version" {
  type = string
}

variable "db_instance" {
type = string
}

variable "security_alb" {
  type = string
}

variable "private_subnets" {
  type = list(string)
}
resource "aws_db_instance" "mysql" {
  allocated_storage = 20
  engine = var.engine_name
  engine_version = var.engine_version
  instance_class = var.db_instance
  username = "admin"
  password = "admin123"
  publicly_accessible = true
  vpc_security_group_ids = [var.security_alb]
  db_subnet_group_name = aws_db_subnet_group.rds_subnet_grp.name
}

resource "aws_db_subnet_group" "rds_subnet_grp" {
  name = "rds-subnet-group"
  subnet_ids = [var.private_subnets[0],var.private_subnets[1]]
}