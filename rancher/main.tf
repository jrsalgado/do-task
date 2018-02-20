variable "rancher_server_public_dns" {}

# Rancher provider
provider "rancher" {
  api_url    = "http://${var.rancher_server_public_dns}:8080"
}

# Rancher Environments
 # Rancher demo environment
resource "rancher_environment" "demo" {  
  name = "task-demo"  
  description = "Demonstration environment"  
  orchestration = "swarm"
}

 # Rancher registration token
resource "rancher_registration_token" "demo-token" {  
  environment_id = "${rancher_environment.demo.id}"  
  name = "demo-token"  
  description = "Host registration token for Demo environment"
}
