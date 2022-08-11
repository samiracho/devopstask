# VPC
resource "aws_vpc" "devopstask_vpc" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = "true"
  enable_dns_hostnames = "true"
  tags = {
    Name = "${var.environment}-devopstask-vpc"
  }
}

# Subnet
resource "aws_subnet" "devopstask_public_subnet" {
  vpc_id                  = aws_vpc.devopstask_vpc.id
  cidr_block              = var.vpc_public_subnet_cidr
  map_public_ip_on_launch = true
  availability_zone       = var.vpc_public_subnet_az
  tags = {
    Name = "${var.environment}-public-subnet"
  }
}

# Internet gateway
resource "aws_internet_gateway" "devopstask_igw" {
  vpc_id = aws_vpc.devopstask_vpc.id
}

resource "aws_route_table" "devopstask_public_routetable" {
  vpc_id = aws_vpc.devopstask_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.devopstask_igw.id
  }
  tags = {
    Name = "${var.environment}-public-routetable"
  }
}

# Associate route table with public subnet
resource "aws_route_table_association" "devopstask_public_routetable_association" {
  subnet_id      = aws_subnet.devopstask_public_subnet.id
  route_table_id = aws_route_table.devopstask_public_routetable.id
}
