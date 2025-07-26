# Get information about available AZs
data "aws_availability_zones" "available" {
  state = "available"
}

# Get the current region
data "aws_region" "current" {}

# Get the current caller identity
data "aws_caller_identity" "current" {}

# Create a VPC using data source information
resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name        = "${var.environment}-vpc"
    Environment = var.environment
    Project     = var.project_name
    ManagedBy   = "terraform"
    Region      = data.aws_region.current.name
    AccountID   = data.aws_caller_identity.current.account_id # <-- add value here
  }
}

resource "aws_subnet" "subnet" {
  count             = 3
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.subnet_cidr_blocks[count.index]
  availability_zone = var.availability_zones[count.index]

  tags = {
    Name = "subnet-count-${count.index + 1}"
    Tier = count.index < 1 ? "public" : "private"
  }
}

# Subnets created with for_each
resource "aws_subnet" "subnet_foreach" {
  for_each          = var.subnet_config
  vpc_id            = aws_vpc.main.id
  cidr_block        = each.value
  availability_zone = var.subnet_azs[each.key]

  tags = {
    Name = "subnet-${each.key}"
    Tier = "standard"
  }
}

# Refactored Security Groups using count
resource "aws_security_group" "sg" {
  count       = 3 # Creating 3 security groups
  name        = "${var.security_groups[count.index].name}-sg"
  description = var.security_groups[count.index].description
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port   = var.security_groups[count.index].ingress_port
    to_port     = var.security_groups[count.index].ingress_port
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/16"] # Using the same CIDR for simplicity
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1" # -1 means all protocols
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.security_groups[count.index].name}-sg"
  }
}

# Security groups created with for_each
resource "aws_security_group" "sg_foreach" {
  for_each    = var.security_group_config
  name        = "${each.key}-sg-foreach"
  description = "Security group for ${each.key} servers"
  vpc_id      = aws_vpc.main.id

  tags = {
    Name = "${each.key}-sg-foreach"
  }
}

# Security group rules created with for_each
resource "aws_security_group_rule" "ingress_foreach" {
  for_each          = var.security_group_config
  type              = "ingress"
  from_port         = each.value
  to_port           = each.value
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.sg_foreach[each.key].id
}

# Create multiple route tables
# resource "aws_route_table" "example" {
#   count  = var.route_table_count
#   vpc_id = aws_vpc.main.id

#   tags = {
#     Name = "route-table-${count.index + 1}"
#   }
# }

resource "aws_route_table" "rt" {
  for_each = var.route_tables
  vpc_id   = aws_vpc.main.id

  tags = {
    Name        = "${each.key}-rt"
    Description = each.value
  }
}