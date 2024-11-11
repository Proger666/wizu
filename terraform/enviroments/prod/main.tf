locals {
  installation_region = "us-east-2"
}
provider "aws" {
  region  = local.installation_region
  profile = "wiz-builder"
  default_tags {
    tags = {
      ManagedBy = "Terraform"
      Project   = "Wiz"
    }
  }
}

data "aws_secretsmanager_secret" "db_credentials" {
  name = "prod/db_credentials"
}

data "aws_secretsmanager_secret_version" "db_credentials" {
  secret_id = data.aws_secretsmanager_secret.db_credentials.id
}

# Module for infrastructure
module "prod_infra" {
  source = "../../modules/infra"

  installation_region = local.installation_region

  # VPC Configuration
  vpc_cidr           = "10.0.0.0/16"
  availability_zones = ["us-east-2a", "us-east-2b", "us-east-2c"]
  private_subnets    = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  public_subnets     = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]
  enable_nat_gateway = true           # Enable NAT for private subnets if required
  ssh_key_pair_name  = "prod-keypair" # Default EC2 ssh keypair

  # Database EC2 Configuration
  database_hostname                = "db-instance"
  database_instance_type           = "t3.micro"
  database_allowed_ssh_cidr_blocks = ["0.0.0.0/0"] # We are brave!
  database_username                = jsondecode(data.aws_secretsmanager_secret_version.db_credentials.secret_string)["username"]
  database_password                = jsondecode(data.aws_secretsmanager_secret_version.db_credentials.secret_string)["password"]

  # General Tags
  name_prefix = "crackme"
  environment = "prod"

  # EKS Configuration
  eks_cluster_name       = "prod-eks-cluster"
  eks_cluster_version    = "1.29"
  eks_node_instance_type = "t3.small"
  # Docker Image for the Web Application
  web_app_image = "jeffthorne/tasky:latest"

  # IAM Roles and Permissions
  enable_cluster_creator_admin_permissions = true
}