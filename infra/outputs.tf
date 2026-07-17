# -----------------------------------------------------------
# PROJECT OUTPUTS
# -----------------------------------------------------------

output "vpc_id" {
  description = "ID of created VPC"
  value       = aws_vpc.main.id
}

output "ec2_public_ip" {
  description = "The static Elastic IP address attached to the EC2 server"
  value       = aws_eip.web_eip.public_ip
}

output "rds_endpoint" {
  description = "The connection endpoint for the RDS PostgreSQL database"
  value       = aws_db_instance.postgres.endpoint
}