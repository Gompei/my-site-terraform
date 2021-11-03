terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.58"
    }
  }

  backend "s3" {
  }
}

provider "aws" {
  region = var.region

  default_tags {
    tags = {
      project = var.project_name
    }
  }
}
