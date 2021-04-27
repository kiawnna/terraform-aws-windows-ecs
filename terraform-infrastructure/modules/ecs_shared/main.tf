locals {
  # pass in user data as a file also
  cluster_name = "${var.company}-shared-${var.region}-${var.environment}-ecs-cluster"
//  ad_file_name = var.ad_file_name
  user_data = <<EOF
//<powershell>
//Set-DefaultAWSRegion -Region ${var.region}
//Set-Variable -name instance_id -value (Invoke-Restmethod -uri http://169.254.169.254/latest/meta-data/instance-id)
//New-SSMAssociation -InstanceId $instance_id -Name "${local.ad_file_name}"
//</powershell>
EOF
}

# ECS Cluster for all applications.
resource "aws_ecs_cluster" "ecs-cluster" {
  name               = "${var.company}-shared-${var.region}-${var.environment}-ecs-cluster"
  capacity_providers = [aws_ecs_capacity_provider.capacity-provider.name]

  default_capacity_provider_strategy {
    capacity_provider = aws_ecs_capacity_provider.capacity-provider.name
    weight            = 1
  }
}

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/spot_fleet_request#spot_maintenance_strategies
resource "aws_autoscaling_group" "asg" {
  name = "${var.company}-shared-${var.region}-${var.environment}-asg"
  vpc_zone_identifier = var.subnet_ids
//  desired_capacity = var.desired_capacity
  max_size = var.max_size
  min_size = var.min_size
  protect_from_scale_in = true
//  capacity_rebalance  = true // optional see here though: https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/spot-fleet.html#spot-fleet-capacity-rebalance

//   NEW STUFF
//  lifecycle {
//    ignore_changes = [desired_capacity]
//  }

  tag {
    key                 = "AmazonECSManaged"
    value               = ""
    propagate_at_launch = true
  }
  // END NEW STUFF

  tag {
    key = "Name"
    propagate_at_launch = true
    value = "${var.company}-shared-${var.region}-${var.environment}-instance"
  }

  mixed_instances_policy {
    launch_template {
      launch_template_specification {
        launch_template_id = aws_launch_template.launch-template.id
        version = "$Latest"
      }

      override {
        instance_type     = var.spot_instance_types[0]
        weighted_capacity = "1"
      }

      override {
        instance_type     = var.spot_instance_types[1]
        weighted_capacity = "1"
      }

      override {
        instance_type     = var.spot_instance_types[2]
        weighted_capacity = "1"
      }

      override {
        instance_type     = var.spot_instance_types[3]
        weighted_capacity = "1"
      }

      override {
        instance_type     = var.spot_instance_types[4]
        weighted_capacity = "1"
      }

      override {
        instance_type     = var.spot_instance_types[5]
        weighted_capacity = "1"
      }
    }
  }
}

//resource "aws_autoscaling_policy" "target_tracking_policy" {
//  name                   = "foobar3-terraform-test"
//  scaling_adjustment     = 4
//  adjustment_type        = "TargetTrackingScaling"
//  policy_type = "TargetTrackingScaling"
//  cooldown               = 300
//  autoscaling_group_name = aws_autoscaling_group.asg.name
//
//   target_tracking_configuration {
//    predefined_metric_specification {
//      predefined_metric_type = "CapacityProviderReservation"
//    }
//
//    target_value = 90.0
//  }
//}

resource "aws_ecs_capacity_provider" "capacity-provider" {
  name               = "${var.company}-shared-${var.region}-${var.environment}-cap-provider"

  auto_scaling_group_provider {
    auto_scaling_group_arn = aws_autoscaling_group.asg.arn
    managed_termination_protection = "ENABLED"

    managed_scaling {
      maximum_scaling_step_size = 2
      minimum_scaling_step_size = 1
      status                    = "ENABLED"
      target_capacity           = var.capacity_target_percent
    }
  }
  depends_on = []
  tags = {
    Name = "${var.company}-shared-${var.region}-${var.environment}-cap-provider"
    Deployment_Method = "terraform"
  }
}

resource "aws_launch_template" "launch-template" {
  name          = "${var.company}-shared-${var.region}-${var.environment}-launch-template"
  image_id      = var.image_id
  instance_type = var.spot_instance_types[0]
  key_name      = var.key_pair
  vpc_security_group_ids = var.launch_config_security_groups
  user_data = base64encode(local.user_data)
  depends_on = [var.internet_gateway]

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "${var.company}-shared-${var.region}-${var.environment}-instance"
      Deployment_Method = "terraform"
      Registration = "False"
    }
  }

  iam_instance_profile {
    arn = aws_iam_instance_profile.ecs_host_instance_profile.arn
  }

  lifecycle {
    create_before_destroy = true
  }

  tags = {
    Name = "${var.company}-shared-${var.region}-${var.environment}-launch-template"
    Deployment_Method = "terraform"
  }
}

// IAM Roles and policies (all shared)
// Task, role, policy and attachment for the ECS Hosts (EC2 instances the tasks are running on)
resource "aws_iam_role" "ecs_host_role" {
  name = "${var.company}-shared-${var.region}-${var.environment}-ecs-host-role"
  path = "/"

  assume_role_policy = <<EOF
{
   "Version": "2012-10-17",
   "Statement": [
       {
           "Action": "sts:AssumeRole",
           "Principal": {
              "Service": "ec2.amazonaws.com"
           },
           "Effect": "Allow",
           "Sid": ""
       }
   ]
}
EOF
}

resource "aws_iam_instance_profile" "ecs_host_instance_profile" {
  name               = "${var.company}-shared-${var.region}-${var.environment}-inst-profile"
  role               = aws_iam_role.ecs_host_role.name
}

resource "aws_iam_policy" "ecs_host_policy" {
  name = "${var.company}-shared-${var.region}-${var.environment}-ecs-host-policy"
  path = "/"

  policy = <<-EOF
  {
    "Version": "2012-10-17",
    "Statement": [
      {
        "Effect": "Allow",
        "Action": [
          "ec2:*",
          "ecs:*",
          "ecr:*",
          "logs:*",
          "iam:*",
          "ssm:*",
          "fsx:*"
        ],
        "Resource": "*"
      }
    ]
  }
  EOF
}

resource "aws_iam_role_policy_attachment" "ecs_host_attachment" {
  role      = aws_iam_role.ecs_host_role.name
  policy_arn = aws_iam_policy.ecs_host_policy.arn
}

data "aws_iam_policy" "AmazonSSMDirectoryServiceAccess" {
  arn = "arn:aws:iam::aws:policy/AmazonSSMDirectoryServiceAccess"
}

resource "aws_iam_role_policy_attachment" "ecs_host_attachment_ssmdir" {
  role      = aws_iam_role.ecs_host_role.name
  policy_arn = data.aws_iam_policy.AmazonSSMDirectoryServiceAccess.arn
}

data "aws_iam_policy" "AmazonSSMManagedInstanceCore" {
  arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_role_policy_attachment" "ecs_host_attachment_ssm" {
  role      = aws_iam_role.ecs_host_role.name
  policy_arn = data.aws_iam_policy.AmazonSSMManagedInstanceCore.arn
}

// Task, role, policy and attachment for the ECS Task Role (what ECS tasks need after they are running)
resource "aws_iam_role" "task_role" {
  name               = "${var.company}-shared-${var.region}-${var.environment}-taskrole"

  assume_role_policy = <<EOF
{
 "Version": "2012-10-17",
 "Statement": [
   {
     "Sid": "",
     "Effect": "Allow",
     "Principal": {
       "Service": "ecs-tasks.amazonaws.com"
     },
     "Action": "sts:AssumeRole"
   }
 ]
}
EOF
}

resource "aws_iam_policy" "task_policy" {
  name = "${var.company}-shared-${var.region}-${var.environment}-task-policy"
  path = "/"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "logs:*"
      ],
      "Effect": "Allow",
      "Resource": "*"
    }
  ]
}
EOF
}

resource "aws_iam_policy_attachment" "task_role_attachment" {
  name       = "${var.company}-shared-${var.region}-${var.environment}-policy-attach"
  roles      = [aws_iam_role.task_role.name]
  policy_arn = aws_iam_policy.task_policy.arn
}

// Task, role, policy and attachment for the ECS Task Execution Role (what ECS tasks need in order to launch)
resource "aws_iam_role" "task_execution_role" {
  name               = "${var.company}-shared-${var.region}-${var.environment}-taskExRole"
  assume_role_policy = <<EOF
{
 "Version": "2012-10-17",
 "Statement": [
   {
     "Sid": "",
     "Effect": "Allow",
     "Principal": {
       "Service": "ecs-tasks.amazonaws.com"
     },
     "Action": "sts:AssumeRole"
   }
 ]
}
EOF
}

resource "aws_iam_role_policy" "task_execution_policy" {
  role   = aws_iam_role.task_execution_role.name
  policy = <<-EOF
  {
    "Version": "2012-10-17",
    "Statement": [
      {
        "Effect": "Allow",
        "Action": [
          "ec2:*",
          "ecs:*",
          "ecr:*",
          "logs:*",
          "iam:*",
          "ssm:*",
          "fsx:*"
        ],
        "Resource": "*"
      }
    ]
  }
  EOF
}
