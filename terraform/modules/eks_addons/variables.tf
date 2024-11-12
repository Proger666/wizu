variable "eks_oidc_arn" {
  type = string
}

variable "eks_cluster_id" {
  type = string
}

variable "install_argo" {
  type    = bool
  default = false
}

variable "install_aws_lb_controller" {
  type    = bool
  default = true
}

variable "install_external_secrets_operator" {
  type    = bool
  default = false
}

variable "installation_region" {
  description = "Region where resources will be deployed"
  type        = string
  default     = "us-east-2"
}