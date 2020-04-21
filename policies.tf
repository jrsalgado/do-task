data "aws_iam_policy_document" "s3_policies_document" {
  statement {
    sid = "S3ReadWritteAccess"

    actions = [
      "s3:GetObject",
        "s3:PutObject",
    ]

    resources = [
      "arn:aws:s3:::terraform-states.nearsoft/ns-task.tfstate",
    ]
  }
}

data "aws_iam_policy_document" "ec2_policies_document" {
  statement {
    sid = "CreateEc2Instance"

    actions = [
        "ec2:RunInstances",
        "ec2:StartInstances",
        "ec2:StopInstances",
    ]

    resources = [
      "*",
    ]

    condition {
        test     = "StringEquals"
        variable = "ec2:InstanceType"

      values = [
        "t2.micro",
      ]
    }

    condition {
        test     = "StringEquals"
        variable = "ec2:Region"

        values = [
            "us-east-1",
        ]
    }
  }
}

resource "aws_iam_policy" "s3_policies" {
  name   = "s3_policies"
  path   = "/"
  policy = "${data.aws_iam_policy_document.s3_policies_document.json}"
}

resource "aws_iam_policy" "ec2_policies" {
  name   = "ec2_policies"
  path   = "/"
  policy = "${data.aws_iam_policy_document.ec2_policies_document.json}"
}