module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 5.0"

  name = var.vpc_name
  cidr = var.vpc_cidr

  azs             = var.availability_zones
  private_subnets = var.private_subnets
  public_subnets  = var.public_subnets

  #tagging for AWS ALB controller
  public_subnet_tags = {
    "kubernetes.io/role/elb" = "1"
  }

  #tagging for AWS ALB controller
  private_subnet_tags = {
    "kubernetes.io/role/internal-elb" = "1"
  }
  enable_nat_gateway = var.enable_nat_gateway

}

