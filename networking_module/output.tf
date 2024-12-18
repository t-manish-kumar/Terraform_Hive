output "vpc_id" {
  value = aws_vpc.myvpc.id
}

output "public_subnets_ids" {
  value = aws_subnet.public_subnets_alb[*].id
}

output "private_subnets_ids" {
  value = aws_subnet.private_subnets_alb[*].id
}

output "alb_sg_id" {
  value = aws_security_group.alb_sg.id
}

