provider "aws" {
  region = "us-east-1"
}

# resource "aws_iam_group" "task_interviewers" {
#   name = "task-interviewers"
#   path = "/"
# }

module "user_group_task_interviewers" {
  source = "../../modules/user_group"
  name = "task-interviewers"

  statements = [
    {
      actions  = [
        "s3:GetObject",
        "s3:PutObject",
      ]
      resources = [
        "arn:aws:s3:::terraform-states.nearsoft/ns-task.tfstate",
      ]
    },
    {
      actions  = [
        "s3:List*",
      ]
      resources = [
        "arn:aws:s3:::*",
      ]
    },
    # EC2 permissions
    {
      actions  = [
        "ec2:Create*",
        "ec2:Modify*",
        "ec2:Delete*",
      ]
      resources = [
        "arn:aws:ec2:::*",
      ]
    },
    # VPC Permissions
    {
      actions = [
        "ec2:Describe*",
        "ec2:CreateSecurityGroup",
        "ec2:AuthorizeSecurityGroupEgress",
        "ec2:AuthorizeSecurityGroupIngress",
        "ec2:ImportKeyPair",
        "ec2:DeleteSecurityGroup",
        "ec2:RevokeSecurityGroupEgress",
        "ec2:RevokeSecurityGroupIngress",
        "ec2:CreateLaunchTemplate",
        "ec2:DescribeLaunchTemplates",
        "ec2:DescribeLaunchTemplateVersions",
        "ec2:RunInstances",
      ]
      resources = [
        "*",
      ]
    },
    {
      actions = [
        "autoscaling:CreateAutoScalingGroup",
        "autoscaling:UpdateAutoScalingGroup",
        "autoscaling:Describe*",
      ]

      resources = [
        "*",
      ]
    }
  ]
}

locals {
  # TODO: get out these interviewers and set from a different
  interviewers = {
    "msanchez@nearsoft.com" = {
      groups = [
        module.user_group_task_interviewers.group_name
      ]
    },
    "idelgado@nearsoft.com" = {
      groups = [
        module.user_group_task_interviewers.group_name
      ]
    },
  }
}

resource "aws_iam_user_group_membership" "memberships" {
  for_each = local.interviewers
  user = each.key
  groups = each.value.groups
}
