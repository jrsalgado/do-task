FROM ubuntu:bionic
ENV AWS_ACCESS_KEY_ID="anaccesskey"
ENV AWS_SECRET_ACCESS_KEY="asecretkey"

RUN apt update \
    && apt install curl unzip vim apt-transport-https gnupg -y \
    && curl https://releases.hashicorp.com/terraform/0.12.24/terraform_0.12.24_linux_amd64.zip -o terraform.zip \
    && unzip -o terraform.zip -d terraform \
    && mv terraform/terraform /usr/bin \
    && mkdir /root/.aws

WORKDIR /terraform
