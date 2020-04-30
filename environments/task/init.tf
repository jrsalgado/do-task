##########################################################################
# This file is supposed to have infrastructure created already and basic #
# utils functions (or data) to be easier future configurations           #
##########################################################################

data "aws_vpc" "main" {
  default = "true"
}

# Get all zones availables inside region
data "aws_availability_zones" "available" {
  state = "available"
}

# Set file to configure ssh
data "template_cloudinit_config" "ssh_config" {
  gzip          = false
  base64_encode = true

  # Setup bastion ssh client config
  part {
    filename     = "20_setup_bastion_ssh_client.sh"
    content_type = "text/x-shellscript"
    content      = "${file("./files/ssh-client/bastion_client.sh")}"
  }
}
# Get default ubuntu ami from aws
data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-trusty-14.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}

# Utils
# Getting what is my ip
data "external" "ip" {
  program = ["bash", "-c", "curl -s 'https://ipinfo.io/json'"]
}

