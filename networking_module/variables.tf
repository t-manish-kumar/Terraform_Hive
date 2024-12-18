variable "vpc_cidr" {
  description = "VPC CIDR block"
  type        = string
}

variable "vpc_name" {
  description = "Name of the VPC"
  type        = string
}

variable "public_subnets" {
  description = "List of public subnet CIDR blocks"
  type        = list(string)
}

variable "private_subnets" {
  description = "List of public subnet CIDR blocks"
  type        = list(string)
}

variable "azs" {
  description = "Availability zones for subnets"
  type        = list(string)
}

variable "igw_name" {
  description = "Name of the Internet Gateway"
  type        = string
}

variable "route_table_name" {
  description = "Name of the Route Table"
  type        = string
}

variable "sg_name" {
  description = "Name of the Security Group"
  type        = string
}

