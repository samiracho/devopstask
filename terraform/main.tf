terraform {
  required_version = "1.2.4"

  backend "s3" {
    bucket  = "terraform-state-sami-devopstask"
    key     = "common.tfstate"
    region  = "eu-central-1"
    encrypt = true
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "4.25.0"
    }
  }
}

provider "aws" {
  region = var.region
  default_tags {
     tags = {
        Terraform   = "true"
        Environment = var.environment
     }
  }
}