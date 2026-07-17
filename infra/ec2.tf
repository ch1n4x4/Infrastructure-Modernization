# -----------------------------------------------------------
# DATA SOURCE: LATEST AMAZON LINUX 2023 AMI
# -----------------------------------------------------------

data "aws_ami" "amazon_linux_2023" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-*-x86_64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# -----------------------------------------------------------
# SSH KEY PAIR
# -----------------------------------------------------------

resource "aws_key_pair" "deployer_key" {
  key_name   = "vb-ec2-key"
  public_key = file("C:/Users/HP/.ssh/id_rsa.pub")
}

# -----------------------------------------------------------
# EC2 INSTANCE
# -----------------------------------------------------------

resource "aws_instance" "web" {
  ami           = data.aws_ami.amazon_linux_2023.id
  instance_type = "t3.micro"

  # first public subnet created in the VPC setup
  subnet_id = aws_subnet.public_1.id

  # EC2 security group created in the SG setup
  vpc_security_group_ids = [aws_security_group.ec2_sg.id]
  key_name               = aws_key_pair.deployer_key.key_name

  root_block_device {
    volume_type = "gp3"
    encrypted   = true
    volume_size = 30 # Optional: Default for AL2023 is 8GB
  }
  user_data = <<-EOF
#!/bin/bash
yum update -y
yum install -y postgresql15
EOF

  # EXPLICIT DEPENDENCY: Wait for the network to have internet access
  # before booting the instance so the yum script doesn't fail.
  depends_on = [
    aws_internet_gateway.gw
  ]

  tags = {
    Name = "vb-web-server"
  }
}

# -----------------------------------------------------------
# ELASTIC IP (EIP)
# -----------------------------------------------------------

resource "aws_eip" "web_eip" {
  instance = aws_instance.web.id

  # 'domain' replaces the deprecated 'vpc = true' argument in newer AWS providers
  domain = "vpc"

  tags = {
    Name = "vb-web-server-eip"
  }
}
