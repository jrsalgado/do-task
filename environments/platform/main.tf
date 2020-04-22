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
    }
  ]
}

locals {
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
