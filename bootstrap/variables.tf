variable "bucket_name" {
  description = "The globally unique name for the S3 bucket storing Terraform state"
  type        = string
}

variable "dynamodb_table_name" {
  description = "The name of the DynamoDB table used for state locking"
  type        = string
  default     = "terraform-state-lock"
}