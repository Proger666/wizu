terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
  }

  backend "s3" {
    bucket         = "terraform-state-bucket-gt3l5v4p"
    key            = "prod/terraform.tfstate"
    region         = "us-east-2"
    dynamodb_table = "tflock"
    encrypt        = true
    profile        = "wiz-builder"
  }
}