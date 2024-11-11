output "state_bucket_name" {
  description = "Name of the S3 bucket for Terraform state storage"
  value       = module.terraform_state_s3.bucket_name
}

output "dynamodb_table_name" {
  description = "Name of the DynamoDB table for state locking"
  value       = aws_dynamodb_table.terraform_lock.name
}