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
      instance_types = ["t3.large"]
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
module "eks_blueprints_addons" {
  source  = "aws-ia/eks-blueprints-addons/aws" #AWS SA module
  version = "~> 1.19"

  cluster_name      = module.eks.cluster_name
  cluster_endpoint  = module.eks.cluster_endpoint
  cluster_version   = module.eks.cluster_version
  oidc_provider_arn = module.eks.oidc_provider_arn

  enable_aws_load_balancer_controller = true
  enable_argocd                       = true
  argocd = {
    values = [templatefile("${path.module}/files/argocd_values.yaml", {})]
  }
  enable_external_secrets = true
  external_secrets = {
    values = [templatefile("${path.module}/files/eso_values.yaml", {})]
  }
  enable_cluster_proportional_autoscaler = false
  enable_karpenter                       = false
  enable_kube_prometheus_stack           = false
  enable_metrics_server                  = false
  enable_external_dns                    = false
  enable_cert_manager                    = false
}
