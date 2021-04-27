# Virtual private cloud with custom cidr block.
resource "aws_vpc" "vpc" {
  cidr_block = var.vpc_cidr_block

  tags = {
    Name = "${var.company}-shared-${var.region}-${var.environment}-vpc"
    Deployment_Method = "terraform"
  }
}
# Internet gateway attached to VPC.
resource "aws_internet_gateway" "internet-gateway" {
  vpc_id = aws_vpc.vpc.id

  tags = {
   Name = "${var.company}-shared-${var.region}-${var.environment}-internet-gateway"
   Deployment_Method = "terraform"
  }
}

# Public subnet 1.
resource "aws_subnet" "public-1" {
 availability_zone = "${var.region}a"
 vpc_id = aws_vpc.vpc.id
 cidr_block = var.public_subnet1_cidr_block

 tags = {
   Name = "${var.company}-shared-${var.region}-${var.environment}-public-1"
   Deployment_Method = "terraform"
 }
}

# Public subnet 2.
resource "aws_subnet" "public-2" {
  availability_zone = "${var.region}c"
  vpc_id = aws_vpc.vpc.id
  cidr_block = var.public_subnet2_cidr_block

  tags = {
    Name = "${var.company}-shared-${var.region}-${var.environment}-public-2"
    Deployment_Method = "terraform"
  }
}
// us-west-1 only has two availability zones.
# Public subnet 3.
resource "aws_subnet" "public-3" {
  availability_zone = "${var.region}c"
  vpc_id = aws_vpc.vpc.id
  cidr_block = var.public_subnet3_cidr_block

  tags = {
    Name = "${var.company}-shared-${var.region}-${var.environment}-public-3"
    Deployment_Method = "terraform"
  }
}

# Private subnet 1.
resource "aws_subnet" "private_1" {
  availability_zone = "${var.region}a"
  vpc_id = aws_vpc.vpc.id
  cidr_block = var.private_subnet1_cidr_block

  tags = {
    Name = "${var.company}-shared-${var.region}-${var.environment}-private-1"
    Deployment_Method = "terraform"
  }
}

# Private subnet 2.
resource "aws_subnet" "private_2" {
  availability_zone = "${var.region}c"
  vpc_id = aws_vpc.vpc.id
  cidr_block = var.private_subnet2_cidr_block

  tags = {
    Name = "${var.company}-shared-${var.region}-${var.environment}-private-2"
    Deployment_Method = "terraform"
  }
}

// us-west-1 only has two availability zones
# Private subnet 3.
resource "aws_subnet" "private_3" {
  availability_zone = "${var.region}c"
  vpc_id = aws_vpc.vpc.id
  cidr_block = var.private_subnet3_cidr_block

  tags = {
    Name = "${var.company}-shared-${var.region}-${var.environment}-private-3"
    Deployment_Method = "terraform"
  }
}

# Nat gateway set up in public-subnet-1.
resource "aws_nat_gateway" "nat-gw" {
 allocation_id = aws_eip.nat.id
 subnet_id = aws_subnet.public-1.id

 tags = {
   Name = "${var.company}-shared-${var.region}-${var.environment}-nat-gw"
   Deployment_Method = "terraform"
 }
}
# Allocates an EIP to the nat gateway.
resource "aws_eip" "nat" {
 vpc = true
}

# Public route table.
resource "aws_route_table" "public_route" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.internet-gateway.id
  }

  tags = {
    Name = "${var.company}-shared-${var.region}-${var.environment}-public-rt"
    Deployment_Method = "terraform"
  }
}
# Private route table.
resource "aws_route_table" "private_route" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat-gw.id
  }

  tags = {
   Name = "${var.company}-shared-${var.region}-${var.environment}-private-rt"
   Deployment_Method = "terraform"
  }
}

# Public route table association between public-subnet-1 and the public route table.
resource "aws_route_table_association" "rta-public-1" {
 subnet_id = aws_subnet.public-1.id
 route_table_id = aws_route_table.public_route.id
}

# Public route table association between public-subnet-2 and the public route table.
resource "aws_route_table_association" "rta-public-2" {
 subnet_id = aws_subnet.public-2.id
 route_table_id = aws_route_table.public_route.id
}

# Public route table association between public-subnet-3 and the public route table.
resource "aws_route_table_association" "rta-public-3" {
 subnet_id = aws_subnet.public-3.id
 route_table_id = aws_route_table.public_route.id
}

# Private route table association between public-subnet-2 and the public route table.
resource "aws_route_table_association" "rta_private_1" {
 subnet_id = aws_subnet.private_1.id
 route_table_id = aws_route_table.private_route.id
}

# Private route table association between public-subnet-2 and the public route table.
resource "aws_route_table_association" "rta_private_2" {
 subnet_id = aws_subnet.private_2.id
 route_table_id = aws_route_table.private_route.id
}

# Private route table association between public-subnet-2 and the public route table.
resource "aws_route_table_association" "rta_private_3" {
 subnet_id = aws_subnet.private_3.id
 route_table_id = aws_route_table.private_route.id
}