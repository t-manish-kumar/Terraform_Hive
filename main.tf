provider "aws" {
  region = "us-east-1"
}

module "ec2" {
  source            = "./ec2module"
  ami_value         = "ami-0c02fb55956c7d316"
  ec2_instance_type = "t2.micro"
  security_grps     = module.networking.alb_sg_id
  public_subnets    = tolist(module.networking.public_subnets_ids)
}

module "alb" {
  source         = "./alb_module"
  alb_name       = "my-application-lb"
  security_alb   = module.networking.alb_sg_id
  public_subnets = tolist(module.networking.public_subnets_ids)
  vpcid          = module.networking.vpc_id
  instance_id1   = module.ec2.instance_id1
  instance_id2   = module.ec2.instance_id2
}

module "networking" {
  source           = "./networking_module"
  vpc_cidr         = "192.168.0.0/16"
  vpc_name         = "my_terraform_vpc"
  public_subnets   = ["192.168.1.0/24", "192.168.2.0/24"]
  private_subnets   = ["192.168.3.0/24", "192.168.4.0/24"]
  azs              = ["us-east-1a", "us-east-1b"]
  igw_name         = "MyIGW"
  route_table_name = "MyRouteTable"
  sg_name          = "ALB-SG"
}

module "my_rds" {
  source = "./rds_module"
  engine_name = "mysql"
  engine_version = "8.0"
  db_instance = "db.t3.micro"
  security_alb   = module.networking.alb_sg_id
  private_subnets = tolist(module.networking.private_subnets_ids)
}