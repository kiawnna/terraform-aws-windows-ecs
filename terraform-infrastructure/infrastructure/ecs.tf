// What you need: certificate arn for load balancer, key pair for us-west-2, set variables in `.tfvars` files, hosted zone id, subdomain.

// Shared load balancer
module "load_balancer" {
  source = "../modules/load_balancer"

  cert_arn = var.load_balancer_cert_arn

  region = var.region
  environment = var.environment
  company = var.company
  security_groups = [module.load-balancer-security-group.security_group_id]
  subnets = [module.vpc.subnet_id1, module.vpc.subnet_id2, module.vpc.subnet_id3]
}

// Shared ECS resources module
// (Example: cluster, iam policies / roles, launch config, autoscaling group, etc)
module "ecs_module" {
  source = "../modules/ecs_shared"
  key_pair = var.key_pair
  ad_file_name = var.ad_file_name
  image_id = var.ami_id
  spot_instance_types = ["t3.small","t3a.small", "t2.small", "t3.medium", "t3a.medium", "t2.medium"]
//  spot_instance_types = ["m5.large","m5d.large", "r5.large", "r5d.large", "c5.large", "c5d.large"]
  capacity_target_percent = var.capacity_target_percent
  min_size = 1
  max_size = var.max_size_ecs_hosts
  region = var.region
  environment = var.environment
  company = var.company
  launch_config_security_groups = [module.security_group_shared_launch_config.security_group_id]
  subnet_ids = [module.vpc.private_subnet_id, module.vpc.private_subnet_id2, module.vpc.private_subnet_id3]
  internet_gateway = module.vpc.internet_gateway
}