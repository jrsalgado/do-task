FROM hashicorp/terraform:light

# DECLARE AWS ENV vars

# use your own AWS AMI CREDENTIALS
ENV AWS_ACCESS_KEY_ID="default_access_key"
ENV AWS_SECRET_ACCESS_KEY="default_secret_key"
ENV AWS_DEFAULT_REGION="us-west-1"

# install python
RUN apk add --update python py-pip \
    # install aws
    && pip install awscli \
    # configure AWS
    && aws configure set aws_access_key_id $AWS_ACCESS_KEY_ID \
    && aws configure set aws_secret_access_key $AWS_SECRET_ACCESS_KEY \
    && aws configure set default.region $AWS_DEFAULT_REGION
WORKDIR /usr/terransible

ENTRYPOINT ["terraform"]
