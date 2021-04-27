resource "aws_codepipeline" "pipeline" {
  name     = substr("${var.company_name}-${var.app_name}-${var.environment}-${var.pipeline_name}", 0, 64)
  role_arn = var.role_arn

  artifact_store {
    location = var.bucket
    type     = "S3"
  }

  dynamic stage {
    for_each = length(var.source_actions) > 0 ? [1] : []
    content {
      name = "Source_Github"

      dynamic action {
        for_each = var.source_actions
        content {
          name             = action.value["name"]
          category         = "Source"
          owner            = "ThirdParty"
          provider         = "GitHub"
          version          = "1"
          output_artifacts = [action.value["output_artifact"]]

          configuration = {
            Owner                = action.value["owner"]
            Repo                 = action.value["repo"]
            Branch               = action.value["branch"]
            OAuthToken           = var.github_token
            PollForSourceChanges = action.value["poll"]
          }
        }
      }
    }
  }

  dynamic stage {
    for_each = length(var.build_projects) > 0 ? [1] : []
    content {
      name = "Build"

      dynamic action {
        for_each = var.build_projects
        content {
          name            = action.value["short_name"]
          category        = "Build"
          owner           = "AWS"
          provider        = "CodeBuild"
          input_artifacts = [action.value["input_artifact"]]
          version         = "1"
          run_order       = action.value["run_order"]

          configuration = {
            ProjectName = action.value["name"]
          }
        }
      }
    }
  }

  dynamic stage {
    for_each = length(var.post_build_projects) > 0 ? [1] : []
    content {
      name = "Post_Build"

      dynamic action {
        for_each = var.post_build_projects
        content {
          name            = action.value["short_name"]
          category        = "Build"
          owner           = "AWS"
          provider        = "CodeBuild"
          input_artifacts = [action.value["input_artifact"]]
          version         = "1"
          run_order       = action.value["run_order"]

          configuration = {
            ProjectName = action.value["name"]
          }
        }
      }
    }
  }
}
