# variables.tf

variable "aws_config_bucket_arn" {
  description = "The ARN of the S3 bucket for storing AWS Config data"
  type        = string
}

variable "aws_config_bucket_name" {
  description = "The name of the S3 bucket for storing AWS Config data"
  type        = string
}

variable "environment" {
  description = "The environment tag for AWS Config resources (e.g., prod, dev)"
  type        = string
}

variable "team" {
  description = "The team tag associated with the resources"
  type        = string
  default     = "security"
}

variable "name_prefix" {
  description = "Prefix for naming resources"
  type        = string
  default     = "crackme"
}