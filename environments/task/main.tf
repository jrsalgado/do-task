
provider "aws" {
  region = "us-east-1"
}

locals {
  agCapacity = 1
}


data "aws_vpc" "default" {
  default = "true"
}

data "aws_subnet_ids" "default" {
  vpc_id = data.aws_vpc.default.id
}

# Bastion
  # AutoscalingGroup
  # Launch configuration | launch template
  # Security Group
  # Network
