locals {
  eso_namespace = "external-secrets"
  eso_role_name = eso_irsa_role
}
resource "helm_release" "external_secrets_operator" {
  count = var.install_external_secrets_operator ? 1 : 0

  name             = "external-secrets"
  repository       = "https://charts.external-secrets.io"
  chart            = "external-secrets"
  namespace        = local.eso_namespace
  version          = "0.10.5"
  create_namespace = true

  set {
    name  = "installCRDs"
    value = true
  }
}

data "aws_caller_identity" "current" {}

data "aws_iam_policy_document" "eso_iam_policy" {
  statement {
    effect = "Allow"
    actions = [
      "secretsmanager:GetSecretValue",
      "secretsmanager:DescribeSecret",
    ]
    resources = ["arn:aws:secretsmanager:${var.installation_region}:${data.aws_caller_identity.current.account_id}:secret:*"]
  }
}

module "aws_eso_irsa_role" {
  count = var.install_external_secrets_operator ? 1 : 0

  source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  version = "~> 5.0"

  role_name = local.eso_role_name
  role_policy_arns = {
    eso_tools_operator_policy = aws_iam_policy.this[0].arn
  }

  oidc_providers = {
    sts = {
      provider_arn               = var.eks_oidc_arn
      namespace_service_accounts = ["system:serviceaccount:${local.eso_namespace}:eso-operator"]
    }
  }
}

data "aws_iam_policy_document" "this" {
  statement {
    effect    = "Allow"
    actions   = ["sts:AssumeRole"]
    resources = ["*"]
  }
}

resource "aws_iam_policy" "this" {
  count = var.install_external_secrets_operator ? 1 : 0

  name   = "eso-operator-policy"
  policy = data.aws_iam_policy_document.this.json
}