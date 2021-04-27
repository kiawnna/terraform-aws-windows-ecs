// Module for shared CI/CD resources that only need to be created once per environment.
module "cicd_shared_resources" {
  source = "../modules/cicd_shared"
  company_name = var.company
  environment = var.environment
}