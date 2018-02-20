# Providers
 # AWS provider

# TODO: Read terraform configuration
provider "aws" {
  # TODO: Set configurations
}

#Security groups

data "aws_security_group" "rancherServerCustom" {
  id = "${var.security_group_id}"
}

# Simple Rancher Server

resource "aws_instance" "rancherServer" {
  instance_type = "${var.dev_instance_type}"
  ami = "${var.dev_ami}"
  tags {
    Name = "rancherServer"
  }
  key_name = "${aws_key_pair.auth.id}"
  vpc_security_group_ids = ["${data.aws_security_group.rancherServerCustom.id}"]
  
  provisioner "remote-exec" {
    inline = [ 
      "sudo docker run -d --restart=unless-stopped -p 8080:8080 rancher/server" 
    ]

    connection {
      type         = "ssh"
      user         = "ubuntu"
      private_key  = "${file(var.private_key_path)}"
    }
  }
  
  # TODO: --- EXTRA run rancher module after public dns ---
  # provisioner "local-exec" {
  #   command = "sleep 1m && terraform apply -lock=false -auto-approve -var 'rancher_server_public_dns=${aws_instance.rancherServer.public_dns}' rancher"
  # }

}

#key pair

resource "aws_key_pair" "auth" {
  key_name  ="${var.key_name}"
  public_key = "${file(var.public_key_path)}"
}

output "rancher_server_public_dns" {
  value = "${aws_instance.rancherServer.public_dns}"
}
