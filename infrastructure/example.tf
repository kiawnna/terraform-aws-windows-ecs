// example APP ECS resources
module "ecs_example" {
  source = "../modules/ecs_per_app"

  // Change these per application
  subdomain = var.example_subdomain
  hosted_zone_id = var.example_hosted_zone_id
  app_certificate_arn = var.example_app_certificate_arn
  app_name = var.example_app_name
  container_port = var.example_port

  // These remain the same.
  max_task_capacity = var.max_task_capacity
  min_task_capacity = 1
  cluster_name = module.ecs_module.ecs_cluster_name
  container_cpu = var.container_cpu
  container_memory = var.container_memory
  task_desired_count = var.task_desired_count
  substring_length_tg = 32
  lb_dns_name = module.load_balancer.lb_dns_name
  region = var.region
  environment = var.environment
  company = var.company
  capacity_provider_name = module.ecs_module.capacity_provider_name
  ecs_cluster_id = module.ecs_module.ecs_cluster_id
  security_groups = [module.security_group_shared_ecs_services.security_group_id]
  vpc_id = module.vpc.vpc_id
  listener_arn = module.load_balancer.listener_443_arn
  subnets = [module.vpc.private_subnet_id, module.vpc.private_subnet_id2]
  load_balancer_arn = module.load_balancer.load_balancer_arn
  task_execution_role_arn = module.ecs_module.task_execution_role_arn
  task_role_arn = module.ecs_module.task_role_arn
  load_balancer_id = module.load_balancer.load_balancer_id
}

// CodeBuild for example APP
module "example_codebuild_project" {
  source = "../modules/codebuild_project"

  // Change these per application (also change APP in env_vars)
  app_name = var.example_app_name
  project_name = "trigger-step-function"
  tags = {
      Environment = var.environment
      Company = var.company
      Deployment_Method = "terraform"
      App_Name = var.example_app_name
  }

  // Leave all but the APP in env_vars the same.
  environment = var.environment
  company_name = var.company
  artifact_bucket = module.cicd_shared_resources.artifact_bucket
  codebuild_role = module.cicd_shared_resources.codebuild_role_arn
  # pass a buildspec file instead.
  buildspec = <<-EOF
  version: 0.2
  phases:
    build:
      commands:
        - zip -r $COMPANY-$ENV-$APP.zip .
        - aws s3 cp $COMPANY-$ENV-$APP.zip s3://$BUCKET/$COMPANY-$ENV-$APP.zip
        - pip3 install yq
        - StateMachineArn=$(aws ssm get-parameters --names StateMachineArn$ENV | yq -r '.Parameters[0].Value')
        - "aws stepfunctions start-execution --state-machine-arn $StateMachineArn --input '{\"app_name\": \"'$APP'\", \"subnet_id\": \"'$SUBNET_ID'\", \"sec_group_id\": \"'$SECGRP_ID'\", \"instance_profile\": \"'$INSTANCE_PROFILE'\"}'"
EOF
env_vars = [
  {
    name  = "APP"
    value = var.example_app_name
    type  = "PLAINTEXT"
  },
  {
    name  = "COMPANY"
    value = var.company
    type  = "PLAINTEXT"
  },
  {
    name  = "SUBNET_ID"
    value = module.vpc.subnet_id1
    type  = "PLAINTEXT"
  },
  {
    name  = "SECGRP_ID"
    value = module.load-balancer-security-group.security_group_id
    type  = "PLAINTEXT"
  },
  {
    name  = "BUCKET"
    value = module.cicd_shared_resources.artifact_bucket_name
    type  = "PLAINTEXT"
  },
  {
    name  = "ENV"
    value = var.environment
    type  = "PLAINTEXT"
  },
  {
    name  = "INSTANCE_PROFILE"
    value = module.cicd_shared_resources.instance_profile_arn
    type  = "PLAINTEXT"
  }
]
}

// CodePipeline for example APP
module "example_pipeline" {
  source        = "../modules/codepipeline"

  // Change these per application.
  app_name      = var.example_app_name
  source_actions = [
    {
      name            = "GitHub_example"
      output_artifact = "s3_source_artifact"
      owner = var.github_owner
      repo = var.example_repo
      branch = var.branch
      poll = true
    }
  ]
  tags = {
    Environment = var.environment
    Company = var.company
    Deployment_Method = "terraform"
    App_Name = var.example_app_name
  }

   // These remain the same.
  github_token = var.github_token
  pipeline_name = "deployment-pipeline"
  environment   = var.environment
  company_name  = var.company
  role_arn      = module.cicd_shared_resources.pipeline_role_arn
  bucket        = module.cicd_shared_resources.artifact_bucket
  build_projects = [
    {
      name           = module.example_codebuild_project.project_name
      short_name     = module.example_codebuild_project.project_short_name
      run_order      = 1
      input_artifact = "s3_source_artifact"
    }
  ]
}
