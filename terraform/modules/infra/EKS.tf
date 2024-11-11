module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.0"

  # General EKS Cluster Configuration
  cluster_name    = "${var.name_prefix}-${var.environment}-${var.eks_cluster_name}"
  cluster_version = var.eks_cluster_version

  # API Endpoint Accessibility
  cluster_endpoint_public_access = true

  # Add-ons for EKS Cluster
  cluster_addons = {
    coredns    = {}
    kube-proxy = {}
    vpc-cni    = {}
  }

  # Networking Configuration
  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnets

  # EKS Managed Node Group Configuration with Smallest Instances
  eks_managed_node_group_defaults = {
    instance_types = ["t3.small"]
    disk_size      = 50

  }

  eks_managed_node_groups = {
    worker = {
      ami_type       = "AL2_x86_64" # Default EKS AMI type for managed node groups
      instance_types = ["t3.medium"]
      key_name       = var.ssh_key_pair_name
      min_size       = 1
      max_size       = 2
      desired_size   = 2
      disk_size      = 50
    }
  }
  #For SA access via IAM
  enable_irsa = true

  # Permissions and Access Configuration
  enable_cluster_creator_admin_permissions = true
}


#install required infra addons to EKS
module "eks_infra_addons" {
  source = "../eks_addons"

  install_argo              = true
  install_aws_lb_controller = true

  eks_oidc_arn   = module.eks.oidc_provider_arn
  eks_cluster_id = module.eks.cluster_name

  depends_on = [module.eks]
}
