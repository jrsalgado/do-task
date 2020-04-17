#!/bin/bash

docker run -it --rm \
  -v "$(pwd)":/terraform \
  --env-file .secrets/env.list \
  jsalgado/terraform:0.12.24 /bin/bash