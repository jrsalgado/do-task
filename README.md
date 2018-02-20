
# NEARSOFT DEVOPS Task
## Use a Docker container with Terraform (IAC) installed and configured to create and manage your Infrastructure on AWS (Cloud Provider). You will deploy a Rancher server (Container Manager Platform) ready to deploy and manage containers (CaaS)
## Extra: Deploy an Manage APP stack ( set of containers ) on Rancher
___

## Goal set, debug, configure and provision a Rancher server on aws

- You will need to use terraform cli tool to deploy the infrastructure settings from main.tf
- The file main.tf use some variables that you need to configure before attempting to apply changes to AWS, use the file terraform.tfvars and varibles.tf, some of those variables needs to be calculated from aws console.
- Once you set your variables, you can start to attempt to deploy the Rancher Server, you need to build a docker image where the terraform CLI commands can be executed when you run an instace from it, good for you we already set a Dockerfile almost ready to build images from. Build images
 https://docs.docker.com/engine/reference/builder/
 ```sh
# docker build example
docker build -t mydockerhub/myterraformimage:latest .
 ```
- After build your docker image, with your AWS configurations, you can run a docker container with terraform ready to use.
Run containers: https://docs.docker.com/engine/reference/run/
```sh
# docker run example
docker run -it -v "$PWD":/usr/terransible/ --env-file ./private/env.list mydockerhub/myterraformimage:latest apply
 ```
- To use Terraforn CLI from recently created Docker container use a SHELL script where you can use terraform commands like, so you dont need to type the full run command every time:
```sh
# Display the infrastructure plan without apply any change
./terraform.sh plan
# or even better add it to the PATH and use it like
terraform plan
```
- Full terraform CLI commands: https://www.terraform.io/docs/commands/

