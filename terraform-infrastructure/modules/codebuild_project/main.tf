resource "aws_codebuild_project" "project" {
  build_timeout = "20"
  name          = substr("${var.company_name}-${var.app_name}-${var.environment}-${var.project_name}", 0, 64)
  service_role  = var.codebuild_role
  artifacts {
    type = "NO_ARTIFACTS"
  }
  environment {
    compute_type                = var.compute_type
    image                       = var.image
    type                        = "LINUX_CONTAINER"
    image_pull_credentials_type = "CODEBUILD"
    privileged_mode             = true

    dynamic environment_variable {
      for_each = var.env_vars
      content {
        name  = environment_variable.value["name"]
        value = environment_variable.value["value"]
        type  = environment_variable.value["type"]
      }
    }
  }

  source {
    type      = "NO_SOURCE"
    buildspec = var.buildspec
  }

  dynamic vpc_config {
    for_each = var.vpc_config
    content {
      vpc_id             = vpc_config.value["vpc_id"]
      subnets            = vpc_config.value["subnets"]
      security_group_ids = [vpc_config.value["security_group_id"]]
    }
  }
}
