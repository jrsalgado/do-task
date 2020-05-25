provider "aws" {
  region = "us-east-1"
}
#########################################

resource "aws_key_pair" "web" {
  key_name = "web"
  public_key = file("${path.module}/files/private/resources_aws.pub")
}

resource "aws_default_subnet" "bastion" {
  availability_zone = data.aws_availability_zones.available.names[0]
}

resource "aws_default_subnet" "web" {
  availability_zone = data.aws_availability_zones.available.names[1] # different than bastion
}

resource "aws_security_group" "bastion_auth" {
  name        = var.bastion_auth
  vpc_id      = data.aws_vpc.main.id
  description = "Security group for private instances. SSH inbound requests from Bastion host only."

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [aws_default_subnet.bastion.cidr_block] # allow bastion connection
  }
}

resource "aws_launch_template" "web" {
  name_prefix                          = "web-"
  image_id                             = data.aws_ami.ubuntu.id
  instance_type                        = "t2.micro"
  key_name                             = aws_key_pair.web.key_name
  # user_data                            = data.template_cloudinit_config.ssh_config.rendered
  instance_initiated_shutdown_behavior = "terminate"
  ebs_optimized                        = false
  network_interfaces {
    associate_public_ip_address        = true
    delete_on_termination              = true
    subnet_id                          = aws_default_subnet.web.id
    security_groups                    = [aws_security_group.bastion_auth.id]
  }
}

resource "aws_autoscaling_group" "web" {
  name = "web_ag"

  launch_template {
    id = aws_launch_template.web.id
    version = "$Latest"
  }

  vpc_zone_identifier       = [aws_default_subnet.web.id]
  desired_capacity          = var.web_auto_scaling_group_capacity
  min_size                  = var.web_auto_scaling_group_capacity
  max_size                  = var.web_auto_scaling_group_capacity
  health_check_grace_period = "60"
  health_check_type         = "EC2"
  force_delete              = true
  wait_for_capacity_timeout = 0
}
