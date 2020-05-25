provider "aws" {
  region = "us-east-1"
}

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
        "ec2:Delete*",
        "ec2:DescribeLaunchTemplates",
        "ec2:DescribeLaunchTemplateVersions",
        "ec2:RunInstances",
        "ec2:StartInstances",
        "ec2:CreateTags",
        "ec2:Modify*",
        "ec2:CreateSubnet",
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
        "autoscaling:Delete*",
      ]

      resources = [
        "*",
      ]
    },
    {
      actions = [
        "elasticloadbalancing:Create*",
        "elasticloadbalancing:Delete*",
        "elasticloadbalancing:ModifyLoadBalancerAttributes",
        "elasticloadbalancing:Describe*",
        "elasticloadbalancing:ApplySecurityGroupsToLoadBalancer",
        "elasticloadbalancing:AttachLoadBalancerToSubnets",
        "elasticloadbalancing:ModifyTargetGroupAttributes",
        "elasticloadbalancing:SetSecurityGroups",
      ]

      resources = [
        "*",
      ]
    },
    #VPC
     {
      actions = [
        "ec2:CreateVpc", 
        "ec2:CreateSubnet", 
        "ec2:DescribeAvailabilityZones",
        "ec2:CreateRouteTable", 
        "ec2:CreateRoute", 
        "ec2:CreateInternetGateway", 
        "ec2:AttachInternetGateway", 
        "ec2:AssociateRouteTable", 
        "ec2:ModifyVpcAttribute"
      ]

      resources = [
        "*",
      ]
    },
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
