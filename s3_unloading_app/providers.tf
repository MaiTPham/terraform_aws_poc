terraform {
  backend "s3" {}

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.87.0"
    }
  }

}

provider "aws" {
  shared_credentials_files = [var.shared_credentials_file]
  profile                  = var.aws_profile
  region                   = var.region
}