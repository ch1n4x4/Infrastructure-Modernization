# -----------------------------------------------------------
# EC2 SECURITY GROUP
# -----------------------------------------------------------

resource "aws_security_group" "ec2_sg" {
  name        = "vb-ec2-sg"
  description = "Allow inbound HTTP from anywhere and SSH from my IP"
  vpc_id      = aws_vpc.main.id

  # Inbound: SSH restricted to my IP
  ingress {
    description = "SSH access from personal IP"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.my_ip_cidr]
  }

  # Inbound: HTTP open to the public
  ingress {
    description = "HTTP access from the internet"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Outbound: Allow all traffic leaving the EC2 instance
  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "vb-ec2-sg"
  }
}

# -----------------------------------------------------------
# RDS DATABASE TIER SECURITY GROUP
# -----------------------------------------------------------

resource "aws_security_group" "rds_sg" {
  name        = "vb-database-sg"
  description = "Allow PostgreSQL (5432) inbound traffic strictly from the ec2"
  vpc_id      = aws_vpc.main.id

  # Inbound: PostgreSQL access restricted to the EC2 Security Group ID
  ingress {
    description     = "PostgreSQL access from ec2"
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [aws_security_group.ec2_sg.id]
  }

  # Outbound: Allow all traffic leaving the database
  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "vb-database-sg"
  }
}
