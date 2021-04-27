// Global variables
company = "tech"
region = "us-west-1"
load_balancer_cert_arn = "insert a certificate arn here" # ensure you create it in the correct region
key_pair = "key-name" # .pem format in the correct region
github_token = "githubtokenhere" # generate a token in GitHub
github_owner = "GitHubUsername"
ami_id = "ami-0098fa29ecae9965d" # follow instructions for which ami to use from Readme
bastion_ami_id = "ami-0ce1d8c91d5b9ee92" # OpenVPN AMI

// Environment-specific variables
environment = "prod"
branch = "master"
task_desired_count = 2
container_cpu = 750
container_memory = 750
max_size_ecs_hosts = 10
capacity_target_percent = 90
max_task_capacity = 10

// Per Application: EXAMPLE
example_subdomain = "exampledomain.com"
example_app_name = "example"
example_app_certificate_arn = "exampleAppCertificateArn" # exampledomain.com
example_hosted_zone_id = "123456ABCDE" # example.com Hosted Zone Id
example_repo = "ExampleAppGitHubRepo"
example_port = 11233

// Per S3 Website: S3EXAMPLE
s3example_website_domain_name = "exampledomain.com"
s3example_acm_cert_arn = "exampleAppCertificateArn" # exampledomain.com
s3example_hosted_zone_id = "123456ABCDE" # exampledomain.com Hosted Zone Id
s3example_app_name = "s3example"
s3example_repo = "S3ExampleWebsite"
s3example_website_redirect_domain = "staging.redirectexampledomain.com"
s3example_redirect_hosted_zone_id = "987654WXYZ" # Hosted Zone Id for redirectexampledomain.com