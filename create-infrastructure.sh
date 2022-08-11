#!/usr/bin/env bash
set -e

S3_BUCKET="terraform-state-sami-devopstask"
REGION="eu-central-1"

#Check dependencies are installed
if ! [ -x "$(command -v aws)" ]; then
  echo -e 'ERROR: aws cli is not installed. \nPlease check https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html' >&2
  exit 1
fi

if ! [ -x "$(command -v ansible)" ]; then
  echo -e 'ERROR: ansible is not installed. \nPlease check https://docs.ansible.com/ansible/latest/installation_guide/intro_installation.html#installing-and-upgrading-ansible' >&2
  exit 1
fi

#Check if state bucket exists
if ! aws s3api head-bucket --bucket "$S3_BUCKET"; then
  echo "Bucket doesn't exist. Creating bucket"
  aws s3api create-bucket --bucket "$S3_BUCKET" --region "$REGION" --create-bucket-configuration LocationConstraint=$REGION
fi

pushd terraform

terraform init
terraform apply

EC2_PUBLIC_DNS=$(terraform output -raw ec2_instance_public_dns)
ENVIRONMENT=$(terraform output -raw environment)

popd

echo '########################################'
echo 'Infrastructure created'
echo '########################################'
echo ''
echo "Jenkins instance: https://$EC2_PUBLIC_DNS:8443"
echo "SSH: ssh -i $ENVIRONMENT-devopstask-keypair.pem ubuntu@$EC2_PUBLIC_DNS"