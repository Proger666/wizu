variable "bucket_name" {
  description = "Name of the S3 bucket"
  type        = string
}

variable "versioning_enabled" {
  description = "Enable versioning on the S3 bucket"
  type        = bool
  default     = true
}

variable "enable_encryption" {
  description = "Enable server-side encryption"
  type        = bool
  default     = true
}

variable "sse_algorithm" {
  description = "Server-side encryption algorithm"
  type        = string
  default     = "AES256"
}

variable "kms_master_key_id" {
  description = "KMS master key ID for encryption (if required)"
  type        = string
  default     = ""
}

variable "lifecycle_enabled" {
  description = "Enable lifecycle policy"
  type        = bool
  default     = false
}

variable "lifecycle_id" {
  description = "ID for the lifecycle policy"
  type        = string
  default     = "lifecycle-policy"
}

variable "transition_to_ia_days" {
  description = "Days after which to transition objects to Infrequent Access"
  type        = number
  default     = 0
}

variable "transition_to_glacier_days" {
  description = "Days after which to transition objects to Glacier"
  type        = number
  default     = 0
}

variable "ia_storage_class" {
  description = "Storage class for Infrequent Access"
  type        = string
  default     = "STANDARD_IA"
}

variable "glacier_storage_class" {
  description = "Storage class for Glacier"
  type        = string
  default     = "GLACIER"
}

variable "expiration_days" {
  description = "Days after which objects expire"
  type        = number
  default     = 365
}

variable "public_read_access" {
  description = "Enable public read access for S3 bucket"
  type        = bool
  default     = false
}

variable "block_public_acls" {
  description = "Block public ACLs"
  type        = bool
  default     = true
}

variable "ignore_public_acls" {
  description = "Ignore public ACLs"
  type        = bool
  default     = true
}

variable "block_public_policy" {
  description = "Block public bucket policies"
  type        = bool
  default     = true
}

variable "restrict_public_buckets" {
  description = "Restrict public buckets"
  type        = bool
  default     = true
}

variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
}