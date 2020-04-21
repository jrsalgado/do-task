terraform {
  backend "s3" {
    bucket  = "terraform-states.nearsoft"
    key     = "ns-task.tfstate"
    region  = "us-east-1"
  }
}