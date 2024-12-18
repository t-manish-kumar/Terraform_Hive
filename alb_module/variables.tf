variable "alb_name" {
  type = string
}

variable "security_alb" {
  type = string
  }

variable "public_subnets" {
  type = list(string)
}

variable "vpcid" {
  type = string
}
variable "instance_id1" {
  type = string
}
variable "instance_id2" {
  type = string
}