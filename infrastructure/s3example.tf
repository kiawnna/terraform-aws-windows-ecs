// Module called for each static site.
module "s3example_s3website" {
  source = "../modules/s3_static_site"
  website-domain-main = var.s3example_website_domain_name
  acm_certificate_arn = var.s3example_acm_cert_arn
  hosted_zone_id = var.s3example_hosted_zone_id
  website-domain-redirect = var.s3example_website_redirect_domain
  redirect_hosted_zone_id = var.s3example_redirect_hosted_zone_id
}

// CodeBuild for s3example APP
module "s3example_codebuild_project" {
  source = "../modules/codebuild_project"

  // Change these per application (also change APP in env_vars)
  app_name = var.s3example_app_name
  project_name = "trigger-step-function"
  tags = {
      Environment = var.environment
      Company = var.company
      Deployment_Method = "terraform"
      App_Name = var.s3example_app_name
  }

  // Leave all these the same.
  environment = var.environment
  company_name = var.company
  artifact_bucket = module.cicd_shared_resources.artifact_bucket
  codebuild_role = module.cicd_shared_resources.codebuild_role_arn
  buildspec = <<-EOF
  version: 0.2
  phases:
    build:
      commands:
        - aws s3 sync . s3://$BUCKET
        - aws cloudfront create-invalidation --distribution-id $CLOUDFRONT_ID --paths '/*'
EOF
env_vars = [
  {
    name  = "CLOUDFRONT_ID"
    value = module.s3example_s3website.cloudfront_distribution_id
    type  = "PLAINTEXT"
  },
  {
    name  = "BUCKET"
    value = module.s3example_s3website.bucket_name
    type  = "PLAINTEXT"
  }
]
}

// CodePipeline for s3example APP
module "s3example_pipeline" {
  source        = "../modules/codepipeline"

  // Change these per application.
  app_name      = var.s3example_app_name
  source_actions = [
    {
      name            = "GitHub_s3example"
      output_artifact = "s3_source_artifact"
      owner = var.github_owner
      repo = var.s3example_repo
      branch = var.branch
      poll = true
    }
  ]
  tags = {
    Environment = var.environment
    Company = var.company
    Deployment_Method = "terraform"
    App_Name = var.s3example_app_name
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
      name           = module.s3example_codebuild_project.project_name
      short_name     = module.s3example_codebuild_project.project_short_name
      run_order      = 1
      input_artifact = "s3_source_artifact"
    }
  ]
}
