# Dynamically fetch available AZs in our provider's region
data "aws_availability_zones" "available" {
  state = "available"
}

# -----------------------------------------------------------
# VPC
# -----------------------------------------------------------

resource "aws_vpc" "main" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "vaultbridge-main-vpc"
  }
}

# -----------------------------------------------------------
# INTERNET GATEWAY
# -----------------------------------------------------------

resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "vaultbridge-main-igw"
  }
}

# -----------------------------------------------------------
# SUBNETS
# -----------------------------------------------------------

# Public Subnet 1 (AZ A)
resource "aws_subnet" "public_1" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = data.aws_availability_zones.available.names[0]
  map_public_ip_on_launch = true # Automatically assigns public IPs to instances launched here

  tags = {
    Name = "vb-public-subnet-1"
  }
}

# Public Subnet 2 (AZ B)
resource "aws_subnet" "public_2" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.2.0/24"
  availability_zone       = data.aws_availability_zones.available.names[1]
  map_public_ip_on_launch = true

  tags = {
    Name = "vb-public-subnet-2"
  }
}

# Private Subnet 1 (AZ A)
resource "aws_subnet" "private_1" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.10.0/24"
  availability_zone = data.aws_availability_zones.available.names[0]

  tags = {
    Name = "vb-private-subnet-1"
  }
}

# Private Subnet 2 (AZ B)
resource "aws_subnet" "private_2" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.11.0/24"
  availability_zone = data.aws_availability_zones.available.names[1]

  tags = {
    Name = "vb-private-subnet-2"
  }
}

# -----------------------------------------------------------
# ROUTING (Public Route Table & Route to IGW)
# -----------------------------------------------------------

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  # Send all non-local traffic out to the Internet Gateway
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }

  tags = {
    Name = "vb-public-route-table"
  }
}

# -----------------------------------------------------------
# ROUTE TABLE ASSOCIATIONS
# -----------------------------------------------------------

# Associate Public Subnet 1 to the Public Route Table
resource "aws_route_table_association" "public_1" {
  subnet_id      = aws_subnet.public_1.id
  route_table_id = aws_route_table.public.id
}

# Associate Public Subnet 2 to the Public Route Table
resource "aws_route_table_association" "public_2" {
  subnet_id      = aws_subnet.public_2.id
  route_table_id = aws_route_table.public.id
}