terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~>3.63.0"
    }
  }
  required_version = "~>1.0.1"
  backend "s3" {
    profile = "default"
    region  = "us-east-1"
    key     = "terraform.tfstate"
    bucket  = "replace_me"
    encrypt = true
  }
}
