# Terraform Stack
This Terraform stack contains two parts: the `ECS Stack` and the `CI/CD` stack. This stack contains all the resources (from networking to CICD) you 
would need to host Windows applications on ECS, as well as a CICD Step Function pipeline to enable easy testing and deployement of applications.

> **Note**: This stack uses a set naming convention (`{company}-{app_name, where applicable}-{region}-{environment}-resource`)
> and tagging so that it is easy to find resources once deployed to ECS.

### Table of Contents

1. [ECS Stack](#ecs-stack)
2. [CI/CD Stack](#cicd-stack) 
3. [Repository Structure](#repository-structure)
    - [The `infrastructure` directory](#the-infrastructure-directory)
    - [The `modules` directory](#the-modules-directory)
4. [Deploying](#deploying)
5. [Destroying](#destroying)
6. [Troubleshooting](#troubleshooting)
  
# ECS/S3 Website Stack
This ECS/S3 Website stack template uses Terraform's modules capabilities to make organization and deployment of resources in AWS
easy.

For the ECS applications, this stack will deploy:
- The underlying resources necessary for any load-balanced, auto-scaled, and secure ECS stack (shared resources):
    * Highly available Application Load Balancer (ALB) with both an HTTP and HTTPS listener
    * An ECS Cluster
    * An Auto-Scaling Group (ASG)
    * A Capacity Provider (CP)
    * Launch Template for the ECS Host / EC2 instances
    * All necessary IAM roles and policies, scaled down to least-privilege access
- The underlying networking resources to make sure your stack is secure and available:
    * Virtual Private Cloud (VPC)
    * 3 private and 3 public subnets
    * An internet and NAT gateway
    * Public and Private Route Tables
    * 3 Security Groups, one each for your ALB, ECS Host instances, and ECS Services
- Per application hosted on ECS tasks:
    * An ECS Service
    * A task definition
    * A listener rule for your ALB's listener
    * A target group
    * A CloudWatch log group with a metric alarm set to monitor 5XX error codes
    
For the websites hosted in S3, this stack will deploy:
- An S3 bucket for the website and a policy
- An S3 bucket for logs from the website
- A Cloudfront distribution
- Route 53 DNS record
- An S3 bucket for the redirection website (optional)
- A Cloudfront distribution for the redirection website (optional)
- A Route 53 record for the redirection website (optional)
> Note: This module is borrowed from XXXXXXX.
    
# CI/CD Stack
This CI/CD stack is used to implement a CI/CD pipeline using GitHub and AWS resources for Windows applications that can't run on Linux instances.

The `cicd_shared` module only needs to be called **once** and will deploy:
- An S3 bucket to hold your application "artifacts" (zipped files of your application code).
- The IAM Role and Policies necessary for CodeBuild and the instance launched by Serverless to do their magic, all least-privilege

The `codebuild_project` module needs to be called **once per application** and will deploy:
- A CodeBuild Project that accepts a `buildspec` file with the commands needed to run your CI/CD pipeline. You can also refer
to `environment variables` from within each application's file. A couple examples are included in the `example.tf` file.
  
> For the below examples, you could refer to your variables (APP, SUBNET_ID, and COMPANY) with a `$`, ie `$APP`, `$SUBNET_ID`, or `$COMPANY`.

```
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
  }
```

The `codepipeline` module needs to be called **once per application** and will deploy:
- A CodePipeline which defines the source GitHub repository for the codebuild project to use, and controls the releases of changes to
each branch (staging or master).

# Repository Structure
There are two directories in this repository: `infrastructure` and `modules`.

## The `infrastructure` directory
* The `infrastructure` directory is where modules are `instantiated`. If a module is a blueprint for a house, then this directory
  is the actual house being built.
  
* Here is an example of the `vpc` module being called in the `network.tf` file:

  ```
  // Shared VPC.
  module "vpc" {
    source               = "../modules/vpc"
    region               = var.region
    environment = var.environment
    company = var.company
  }
  ```
  > For this resource, note that there are no required fields to input.

You will also find two variable files: `staging.tfvars` and `prod.tfvars`. You will need to edit each of these files with
company and environment-specific information before deploying the stack for the first time. Then, you will need to edit these files
(by following the instructions below) to add new applications to your stack.

In both `staging.tfvars` and `prod.tfvars`, edit the variables under `Global variables` and `Environment-specific variables` as needed.

When generating a GitHub token (in GitHub Settings), you'll need to give the follow access/permissions:
* repo
    * repo:status
    * repo_deployment
    * public_repo
    * repo:invite
    * security_events
* workflow
* write:packages
    * read:packages
* admin:repo_hook
    * write:repo_hook
    * read:repo_hook
    
### Adding new applications
* Each ECS application will have its own `.tf` file. Inside this file will be all the resources that need to be instantiated for each application.
These resources include:
    - A codebuild project module
    - A codepipeline module
    - An ECS module, containing:
        - An ECS service
        - A target group
        - A listener rule
        - A Route 53 record
        - A repository for the application's docker image
        - A cloudwatch log group
        - A listener certificate for secure traffic
    
To add applications to this stack, copy all the resources from any of the already existing application files (ie `example.tf`) and paste
it into a new file (ie `example2.tf`).

> Variables are specific to each application, and have the prefix that matches the name of your fil. As  an example, for
> an application/file called `example`, the variable for the specific application's subdomain might be `example_subdomain`.

Add the following to the end of the `variables.tf` file. Change all references to `example` to a short nickname for the new application.
  ```
  // Application: EXAMPLE
variable "example_subdomain" {
  type = string
}
variable "example_app_name" {
  type = string
  default = "example"
}
variable "example_app_certificate_arn" {
  type = string
}
variable "example_hosted_zone_id" {
  type = string
}
variable "example_repo" {
  type = string
}
variable "example_port" {
  type = string
}
  ```

Next, add the following to the end of the `staging.tfvars` file. Change all references to `example` to a short nickname for the new application. You will also
need to update the values so that they are specific to the new application.
```
// Application: example
example_subdomain = "staging.exampledomainhere.com"
example_app_name = "example"
example_app_certificate_arn = "ArnForApplicationDomainCertificate" # *.exampledomainhere.com
example_hosted_zone_id = "HostedZoneIdForExampleDomain" # exampledomainhere.com Hosted Zone Id
example_repo = "GitHubRepoForExampleApplication"
example_port = 11233 # the application port for the container to run on
```

Repeat the above step for the `prod.tfvars` file, changing the necessary values so that they are application- and environment-specific.

Lastly, in the new `example2.tf` file, update the variable references using `var.example` so that they refer to the newly created variables (`var.example2`)
and not the ones for the old application.

> **Note**: For S3 Websites, follow the same directions above but edit the `s3example.tf` file (and corresponding variables) instead.
> You do not need to upload a `buildspec` file for the S3 website `codebuild module` unless you need unique commands. An example,
> parameterized buildspec is provided by default.

## The `modules` directory
* The `modules` directory should stay untouched unless you are confident in the change you are making.
* This directory is like the blueprint for a house - once it's completed you should only change something if you know it won't affect
  the building process.
* This directory contains all the resource definitions that are used when you instantiate a module in the `infrastructure` directory.

# Deploying
Terraform has a feature called `workspaces` which make deploying resources to two different environments (`staging` and `prod` in this case))
easy and seamless. The instructions below cover creating and deploying to two different workspaces.
    
To deploy resources to AWS, you will need to:
1. Open the `staging.tfvars` file and fill in the values for `company`, `region`, `branch` and `environment`.
    > **Note**: Keep the values for these variables short, lowercase, and free from symbols so that the overall name is not too long. An example of an ALB's name might be:
    `disney-disneyplus-us-east-1-prod-ALB`.
1. Follow the steps above for [adding any new applications](#adding-new-applications).
1. In the `ecs.tf` file:
    * In the `Shared load balancer` module: Enter a `certificate arn` for the domain / domains so that the
      load balancer can direct secure traffic. (You will need to create one in AWS if you do not already have one available for use).
    * In the `Shared ECS resources` module: Enter the `key_pair` to use for launching instances (Create one in AWS if needed). Update the `image_id`
      to use the correct `ami`. The current one is for the `Windows_Server-2019-English-Full-ECS_Optimized-2021.01.13 ami in "us-west-2"`.
1. In the terminal, `cd` into the `infrastructure` and run the following commands, one at a time, to deploy resources for a `staging` environment:
    * `terraform init`
    * `terraform workspace new staging`
    * `terraform workspace select staging` 
    * `terraform apply -var-file="staging.tfvars"` - **note**: A confirmation of `yes` is required after Terraform lists out the resources it plans to build
      in AWS.
        > **NOTE**: If an error about a resource name needing to be 32 characters or fewer occurs shorten the value of the
        > `company` or `app_name` variables.
1. As this is a large stack, it can take up to 10 minutes to deploy. Watch for errors and adjust as necessary.
1. In the terminal, `cd` into the `infrastructure` and run the following commands, one at a time, to deploy resources for a `prod` environment:
    * `terraform workspace new prod`
    * `terraform workspace select prod` 
    * `terraform apply -var-file="prod.tfvars"` - **note**: A confirmation of `yes` is required after Terraform lists out the resources it plans to build
      in AWS.

# Destroying
To delete all resources in AWS that were built by Terraform:
* `cd` into the directory you applied from
* Run the command `terraform workspace select <environment>` for the workspace / environment you would like to destroy.
* Run `terraform destroy` - **note**: Confirmation is required before Terraform will take action just like when applying.

> **NOTE**: Terraform is incredibly powerful and can be used to make deploying, managing, and updating resources in AWS much easier.
It is not, however, without fault. One of these is with the destroy process. Occasionally Terraform does not destroy resources
> in the correct order. Sometimes a small amount of manual work will become necessary.
> 
> If any errors related to:
> * The ECS Service being unable to destroy
> * The ECS Cluster being unable to destroy
> * Security Groups being unable to destroy
> * The Capacity Provider being unable to destroy
> * etc
> 
> occur, `**action is needed**`. In AWS, the Auto-Scaling Group and any running EC2 instances related to the stack you deployed need
> to be manually deleted. Then, run `terraform destroy` again, and the errors should resolve, destroying the rest of the resources.
> 
> If errors still occur, attempt `terraform destroy` once again to account for any timeouts. If the issues still persist, contact
> your cloud guy, Stackoverflow, or terraform support.

# Work in Progress Notes
# Troubleshooting
In order to troubleshoot issues on a container, we suggest logs we enabled and printed for all applications hosted on ECS. Once logs are enabled,
as a part of this stack there is an OpenVPN bastion EC2 instance launched that can be used to securely RDP into the Windows instances. There is some
initial configuration (per local machine, per environment) needed to access the OpenVPN functionality.

## Instructions go here for OpenVPN

## Possible extensions
- Dynamically input correct ami based on region.
- Need to turn buildspec into a file
- Need to turn user data into a file
