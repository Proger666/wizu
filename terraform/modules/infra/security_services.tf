module "aws_config" {
  source                 = "../aws_config"
  aws_config_bucket_name = module.findings_bucket.bucket_name
  aws_config_bucket_arn  = module.findings_bucket.bucket_arn
  name_prefix            = var.name_prefix
  environment            = var.environment
}