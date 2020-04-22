
data "aws_iam_policy_document" "policy_document" {
  dynamic "statement" {
    for_each = [for s in var.statements: {
      actions   = s.actions
      resources = s.resources
    }]

    content {
      actions = statement.value.actions
      resources = statement.value.resources
    }
  }

}

resource "aws_iam_policy" "policy" {
  name   = var.name
  path   = var.path
  policy = data.aws_iam_policy_document.policy_document.json
}

resource "aws_iam_group" "group" {
  name = var.name
  path = var.path
}

resource "aws_iam_group_policy_attachment" "policy_attachment" {
  group      = aws_iam_group.group.name
  policy_arn = aws_iam_policy.policy.arn
}