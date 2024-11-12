locals {
  account_id = "617850135881"
}

module "ecr" {
  source = "terraform-aws-modules/ecr/aws"

  repository_name                   = "${var.environment}-app"
  repository_read_write_access_arns = [module.eks.cluster_iam_role_arn, "arn:aws:iam::617850135881:user/jenkins-temp"]
  repository_lifecycle_policy = jsonencode({
    rules = [
      {
        rulePriority = 1,
        description  = "Keep last 30 images",
        selection = {
          tagStatus     = "tagged",
          tagPrefixList = ["v"],
          countType     = "imageCountMoreThan",
          countNumber   = 30
        },
        action = {
          type = "expire"
        }
      }
    ]
  })
}
