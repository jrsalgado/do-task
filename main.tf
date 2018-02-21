# Providers
 # AWS provider

# TODO: Read terraform configuration
provider "aws" {
  # TODO: Set configurations
  region  = "${var.aws_region}"
  profile = "${var.aws_profile}"
}

# Key pair

resource "aws_key_pair" "auth" {
  key_name  ="${var.key_name}"
  public_key = "${file(var.public_key_path)}"
}

# EC2 Rancher Server

resource "aws_instance" "rancherServer" {
  instance_type = "${var.dev_instance_type}"
  ami = "${var.dev_ami}"
  tags {
    Name = "Rancher Server"
  }
  key_name = "${aws_key_pair.auth.id}"
  vpc_security_group_ids = ["${aws_security_group.my_app_sg.id}"]
  subnet_id = "${aws_subnet.my_app_sn.id}"
    
  depends_on = ["aws_internet_gateway.gw"]
  
  provisioner "remote-exec" {
    inline = [ 
      "sudo docker run -d --restart=unless-stopped -p 8080:8080 rancher/server:v1.6.3" 
    ]

    connection {
      type         = "ssh"
      user         = "ubuntu"
      private_key  = "${file(var.private_key_path)}"
    }
  }
}

# Security Group

resource "aws_security_group" "my_app_sg" {
  name        = "my_rancher_server_sg"
  description = "Allow access for Racher Server"
  vpc_id      = "${aws_vpc.my_app_vpc.id}"
  
  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  ingress {
    from_port   = 2376
    to_port     = 2378
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 4500
    to_port     = 4500
    protocol    = "udp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  ingress {
    from_port   = 500
    to_port     = 500
    protocol    = "udp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Internet access
  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
  }
}

# VPC

resource "aws_vpc" "my_app_vpc" {
  cidr_block            = "10.0.0.0/16"
  enable_dns_hostnames  = true
  enable_dns_support    = true
  tags {
    Name = "my_app_vpc"
  }
}

# Subnet

resource "aws_subnet" "my_app_sn" {
  vpc_id     = "${aws_vpc.my_app_vpc.id}"
  cidr_block = "10.0.0.0/24"
  map_public_ip_on_launch = true
  tags {
    Name = "my_app_sn"
  }
}

# Route Table

resource "aws_route_table" "public" {
  vpc_id = "${aws_vpc.my_app_vpc.id}"
  route {
    cidr_block = "0.0.0.0/0"
	  gateway_id = "${aws_internet_gateway.gw.id}"
	}
  tags {
	Name = "my_app_public"
  }
}

# Route table association

resource "aws_route_table_association" "public_assoc" {
  subnet_id = "${aws_subnet.my_app_sn.id}"
  route_table_id = "${aws_route_table.public.id}"
}

# internet gateway

resource "aws_internet_gateway" "gw" {
  vpc_id = "${aws_vpc.my_app_vpc.id}"
  tags {
    Name = "my_app_iw"
  }
}

# Output 
output "rancher_server_public_dns" {
  value = "${aws_instance.rancherServer.public_dns}"
}
