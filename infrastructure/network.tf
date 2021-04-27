// No variables need to be given a value here.
// Shared VPC.
module "vpc" {
  source               = "../modules/vpc"
  region               = var.region
  environment = var.environment
  company = var.company
}

// Shared security groups for load balancer, ECS Host instances and ECS services.
module "load-balancer-security-group" {
  source = "../modules/security_group"
  vpc_id = module.vpc.vpc_id
  security_group_name = "${var.company}-${var.region}-${var.environment}-lb-security-group"
  ingress_rules = [
    {
      description = "Allow all traffic from internet"
      from_port = 80
      to_port = 80
      protocol = "tcp"
      cidr_block = "0.0.0.0/0"
    },
   {
      description = "Allow secure traffic from internet"
      from_port = 443
      to_port = 443
      protocol = "tcp"
      cidr_block = "0.0.0.0/0"
    }]
  egress_rules = [
    {
      description = ""
      from_port = 0
      to_port = 0
      protocol = "-1"
      cidr_block = "0.0.0.0/0"
    }]
}

module "security_group_shared_ecs_services" {
  source = "../modules/security_group"
  security_group_name = "${var.company}-${var.region}-${var.environment}-ecs-services-security-group"
  vpc_id = module.vpc.vpc_id
  sg_ingress_rules = [
    {
      description = "Allow traffic from load balancer security_group"
      from_port = 0
      to_port = 0
      protocol = "-1"
      security_groups = [module.load-balancer-security-group.security_group_id]
    }]
  egress_rules = [
    {
      description = ""
      from_port = 0
      to_port = 0
      protocol = "-1"
      cidr_block = "0.0.0.0/0"
    }]
}

module "security_group_shared_launch_config" {
  source = "../modules/security_group"
  security_group_name = "${var.company}-${var.region}-${var.environment}-launch-config-security-group"
  vpc_id = module.vpc.vpc_id
  ingress_rules = [
    {
      description = "Allow all traffic."
      from_port = 0
      to_port = 0
      protocol = "-1"
      cidr_block =  "0.0.0.0/0"
    }]
  egress_rules = [
    {
      description = ""
      from_port = 0
      to_port = 0
      protocol = "-1"
      cidr_block = "0.0.0.0/0"
    }]
}
module "security_group_bastion" {
  security_group_name = "${var.environment}-bastion-sg"
  vpc_id = module.vpc.vpc_id
  source = "../modules/security_group"
  ingress_rules = [
    {
      description = "Allow custom udp"
      from_port = 1194
      to_port = 1194
      protocol = "udp"
      cidr_block = "0.0.0.0/0"
    },
   {
      description = "Allow ssh"
      from_port = 22
      to_port = 22
      protocol= "tcp"
      cidr_block = "0.0.0.0/0"
    },
  {
      description = "Allow custom tcp"
      from_port = 945
      to_port = 945
      protocol= "tcp"
      cidr_block = "0.0.0.0/0"
    },
  {
      description = "Allow custom tcp"
      from_port = 943
      to_port = 943
      protocol= "tcp"
      cidr_block = "0.0.0.0/0"
    },
  {
      description = "Allow https"
      from_port = 443
      to_port = 443
      protocol= "tcp"
      cidr_block = "0.0.0.0/0"
    },
     {
      description = "Allow custom tcp"
      from_port = 3389
      to_port = 3389
      protocol= "tcp"
      cidr_block = "0.0.0.0/0"
    }
]
  egress_rules = [
    {
      description = ""
      from_port = 0
      to_port = 0
      protocol = "-1"
      cidr_block = "0.0.0.0/0"
    }]
}

