# Configure the AWS provider with region and profile

provider "aws" {
  region  = "us-east-2" # Ohio region
  profile = "wiz"       # "wiz" profile for authentication via aws-vault

  default_tags {
    tags = {
      ManagedBy = "Terraform"
      Project   = "Wiz"
    }
  }

}