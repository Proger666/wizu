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