provider "aws" {
  region = "us-east-1"
}

locals {
  agCapacity = 1
  auth_middleware = "auth"
}

# Get all zones availables inside region
data "aws_availability_zones" "available" {
  state = "available"
}

data "aws_vpc" "main" {
  default = "true"
}

resource "aws_default_subnet" "bastion" {
  availability_zone = data.aws_availability_zones.available.names[0]
}

resource "aws_default_subnet" "my_awesome_resource" {
  availability_zone = data.aws_availability_zones.available.names[1] # different than bastion
}

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

resource "aws_security_group" "bastion_auth" {
  name        = local.auth_middleware
  vpc_id      = data.aws_vpc.main.id
  description = "Security group for private instances. SSH inbound requests from Bastion host only."

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [data.aws_vpc.main.cidr_block] # allow bastion connection
  }

  ########################################################################################
  # Different approach
  # resource "aws_security_group_rule" "allow_bastion_sg_outbound_bastion_private_sg" {  #
  #   type              = "ingress"                                                      #
  #   security_group_id = aws_security_group.bastion_private_sg.id                       #
  #   protocol                 = local.tcp_protocol                                      #
  #   from_port                = local.ssh_port                                          #
  #   to_port                  = local.ssh_port                                          #
  #   source_security_group_id = aws_security_group.bastion_sg.id                        #
  # }                                                                                    #
  ########################################################################################
}

resource "aws_key_pair" "my_awesome_resource" {
  key_name = "resource"
  public_key = file("${path.module}/files/private/resources_aws.pub")
}

resource "aws_launch_template" "my_awesome_resource" {
  name_prefix                          = "web-"
  image_id                             = data.aws_ami.ubuntu.id
  instance_type                        = "t2.micro"
  key_name                             = aws_key_pair.my_awesome_resource.key_name
  user_data                            = data.template_cloudinit_config.user_data.rendered
  instance_initiated_shutdown_behavior = "terminate"
  ebs_optimized                        = false
  network_interfaces {
    associate_public_ip_address        = true
    delete_on_termination              = true
    # TODO: getFromSet custom function
    subnet_id                          = aws_default_subnet.my_awesome_resource.id
    security_groups                    = [
      "${aws_security_group.bastion_auth.id}"
    ]
  }
}

resource "aws_autoscaling_group" "my_awesome_resource" {
  name = "web_ag"

  launch_template {
    id = aws_launch_template.my_awesome_resource.id
    version = "$Latest"
  }

  vpc_zone_identifier = [aws_default_subnet.my_awesome_resource.id]
  desired_capacity          = local.agCapacity
  min_size                  = local.agCapacity
  max_size                  = local.agCapacity
  health_check_grace_period = "60"
  health_check_type         = "EC2"
  force_delete              = true
  wait_for_capacity_timeout = 0
}
