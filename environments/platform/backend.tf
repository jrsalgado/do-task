terraform {
  backend "s3" {
    bucket  = "terraform-states.nearsoft"
    key     = "ns-platform.tfstate"
    region  = "us-east-1"
  }
}