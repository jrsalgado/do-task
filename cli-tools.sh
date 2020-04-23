#!/bin/bash
docker_image='jsalgado/terraform:0.12.24'
env_list='.secrets/env.list'

function build_image()
{
  docker build -t ${docker_image} .
}

function run_image()
{
  # Mount terraform code
  # Mount your kubectl configurations
  # Load your secrets
  if [[ -f .secrets/env.list ]]; then
      docker run -it --rm \
      -v "$(pwd)":/terraform \
      --env-file ${env_list} \
      ${docker_image} /bin/bash
  else
      echo "Please create .secrets/env.list file before running the container";
      exit 1
  fi
}


function build_once_and_run()
{
  # Build if imaage if not exists
  if [[ "$(docker image ls -q ${docker_image})" = "" ]]; then
    # Build
    build_image && run_image
  else
    # Run
    run_image
  fi
}

function help()
{
   # Display Help
   echo "CTI CLI tools container"
   echo
   echo "Syntax: run-container.sh [-b|r|h]"
   echo "options:"
   echo "-b|--build-only     Build only CLI tools image ${docker_image}."
   echo "-h|--help           Print this Help."
   echo "-r|--run-only       Run a ${docker_image} container."
   echo "-R|--build-run      Rebuild ${docker_image} image and run container,"
   echo "*                   [default] Build image if not exists and run." 
}

case $1 in
  --build-only|-b)
    build_image;
    exit 0
  ;;
  --run-only|-r)
    run_image
    exit 0
  ;;
  --help|-h)
    help
    exit 0
  ;;
  --build-run|-R)
    build_image && run_image
    exit 0
  ;;
  *)
    build_once_and_run
    exit 0
  ;;
esac