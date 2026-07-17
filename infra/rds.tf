# -----------------------------------------------------------
# RDS DB SUBNET GROUP
# -----------------------------------------------------------
resource "aws_db_subnet_group" "rds_subnet_group" {
  name        = "vb-main-rds-subnet-group"
  description = "Subnet group for RDS spanning both private subnets"

  # two private subnets from VPC setup
  subnet_ids = [aws_subnet.private_1.id, aws_subnet.private_2.id]

  tags = {
    Name = "vb-main-rds-subnet-group"
  }
}

# -----------------------------------------------------------
# RDS DB PARAMETER GROUP
# -----------------------------------------------------------
resource "aws_db_parameter_group" "rds_pg" {
  name   = "postgres15-log-connections-pg"
  family = "postgres15"

  parameter {
    name  = "log_connections"
    value = "1" # 1 translates to "on" in PostgreSQL
  }

  tags = {
    Name = "postgres15-log-connections-pg"
  }
}

# -----------------------------------------------------------
# RDS DATABASE INSTANCE
# -----------------------------------------------------------
resource "aws_db_instance" "postgres" {
  identifier          = "vb-postgres-db"
  engine              = "postgres"
  engine_version      = "15"
  instance_class      = "db.t3.micro"
  allocated_storage   = 20
  storage_type        = "gp3"
  storage_encrypted   = true
  publicly_accessible = false
  skip_final_snapshot = true # for this exercise, not recommended

  # Attaching the subnet group and parameter group defined above
  db_subnet_group_name = aws_db_subnet_group.rds_subnet_group.name
  parameter_group_name = aws_db_parameter_group.rds_pg.name

  # Attaching the database security group
  vpc_security_group_ids = [aws_security_group.rds_sg.id]

  # Initial Database Setup
  db_name = "vaultbridge_db"
  # Use a variable for username and password.
  username = var.db_username
  password = var.db_password

  tags = {
    Name = "vb-postgres-db"
  }
}
