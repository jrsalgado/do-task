# Getting what is my ip
data "external" "what_is_my_ip" {
  program = ["bash", "-c", "curl -s 'https://ipinfo.io/json'"]
}

resource "aws_security_group" "bastion_ssh" {
  name        = "bastion-ssh"
  description = "Allow SSH inbound traffic"
  vpc_id      = data.aws_vpc.main.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    # Please restrict your ingress to only necessary IPs and ports.
    # Opening to 0.0.0.0/0 can lead to security vulnerabilities.
    # $(curl -s http://checkip.amazonaws.com)
    cidr_blocks = ["${data.external.what_is_my_ip.result.ip}/32"] # add a CIDR block here
  }

  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
  }
}

data "template_cloudinit_config" "user_data" {
  gzip          = false
  base64_encode = true

  # Setup bastion ssh client config
  part {
    filename     = "20_setup_bastion_ssh_client.sh"
    content_type = "text/x-shellscript"
    content      = "${file("./files/ssh-client/bastion_client.sh")}"
  }
}

resource "aws_key_pair" "bastion" {
  key_name = "bastion"
  public_key = file("${path.module}/files/private/futuredevops_bastion.pub")
}

resource "aws_launch_template" "bastion" {
  name_prefix                          = "bastion-"
  image_id                             = "ami-0a313d6098716f372"
  instance_type                        = "t2.micro"
  key_name                             = aws_key_pair.bastion.key_name
  user_data                            = data.template_cloudinit_config.user_data.rendered
  instance_initiated_shutdown_behavior = "terminate"
  ebs_optimized                        = false
  network_interfaces {
    associate_public_ip_address        = true
    delete_on_termination              = true
    subnet_id                          = aws_default_subnet.bastion.id
    security_groups                    = [
      "${aws_security_group.bastion_ssh.id}"
      ]
  }
}

resource "aws_lb" "bastion" {
  name               = "bastion"
  internal           = false
  load_balancer_type = "network"
  subnets            = [aws_default_subnet.bastion.id, aws_default_subnet.my_awesome_resource.id]
  security_groups = [aws_security_group.bastion_ssh.id]
  enable_deletion_protection = false # to delete
}

resource "aws_lb_target_group" "bastion" {
  name     = "bastion"
  port     = 22
  protocol = "TCP"
  vpc_id   = data.aws_vpc.main.id
}

resource "aws_lb_listener" "ssh" {
  load_balancer_arn = aws_lb.bastion.arn
  port              = 22
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.bastion.arn
  }
}

resource "aws_autoscaling_group" "bastion" {
  name = "bastion-ag"
  # availability_zones = ["us-east-1"]: lets deep into

  launch_template {
    id = aws_launch_template.bastion.id
    version = "$Latest"
  }

  target_group_arns = [aws_lb_target_group.bastion.arn] # i dont know this
  vpc_zone_identifier = [aws_default_subnet.bastion.id]
  desired_capacity          = local.agCapacity
  min_size                  = local.agCapacity
  max_size                  = local.agCapacity
  health_check_grace_period = "60"
  health_check_type         = "EC2"
  force_delete              = true
  wait_for_capacity_timeout = 0
}
