output "policy_name" {
  value = aws_iam_policy.policy.id
}

output "group_name" {
  value = aws_iam_group.group.name
}