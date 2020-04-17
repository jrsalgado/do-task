
provider "aws" {
  region = "us-east-1"
}


resource "aws_iam_user" "lb" {
  name = "msanchez@nearsoft.com"
  path = "/"
  tags = {
    role = "platform"
    version = "version1"
  }
}

resource "aws_iam_user" "user_1" {
  name = "idelgado@nearsoft.com"
  path = "/"
  tags = {
    role = "platform"
    version = "version1"
  }
}

