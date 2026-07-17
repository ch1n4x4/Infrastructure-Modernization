output "state_s3_name" {
  value = aws_s3_bucket.tf_state.bucket
  description = "Output name of terraform state of bucket"
}