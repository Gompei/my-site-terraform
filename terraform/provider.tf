terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.58"
    }
  }

  backend "s3" {
    bucket = "gompei-terraform-bucket"
    key    = "my-site/terraform.tfstate"
    region = "ap-northeast-1"
  }
}

provider "aws" {
  region = "ap-northeast-1"

  default_tags {
    tags = {
      project = var.project_name
    }
  }
}

provider "aws" {
  region = "us-east-1"
  alias  = "us-east-1"

  default_tags {
    tags = {
      project = var.project_name
    }
  }
}

data "terraform_remote_state" "my-aws-settings" {
  backend = "s3"

  config = {
    bucket = "gompei-terraform-bucket"
    key    = "settings/terraform.tfstate"
    region = "ap-northeast-1"
  }
}
