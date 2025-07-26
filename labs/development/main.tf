# Get information about available AZs
data "aws_availability_zones" "available" {
  state = "available"
}

# Get the current region
data "aws_region" "current" {}

# Get the current caller identity
data "aws_caller_identity" "current" {}

# Create a VPC using data source information
resource "aws_vpc" "production" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name        = "${var.environment}-vpc"
    Environment = var.environment
    Project = var.project_name
    ManagedBy   = "terraform"
    Region      = data.aws_region.current.name
    AccountID = data.aws_caller_identity.current.account_id # <-- add value here
  }
}

resource "aws_subnet" "private" {
  vpc_id                  = aws_vpc.production.id
  cidr_block              = var.subnet_cidr # <-- update value here
  availability_zone       = data.aws_availability_zones.available.names[0] # <-- update value here
  map_public_ip_on_launch = false

  tags = {
    Name = "${var.environment}-private-subnet" # <-- update value here
    Environment = var.environment # <-- update value here
    Project = var.project_name # <-- update value here
    ManagedBy = "terraform"
    Region = data.aws_region.current.name # <-- update value here
    AZ = data.aws_availability_zones.available.names[0] # <-- update value here
  }
}

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.production.id

  tags = {
    Name = "${var.environment}-route-table" # <-- update value here
    Environment = var.environment # <-- update value here
    Project = var.project_name # <-- update value here
    ManagedBy = "terraform"
    Region = data.aws_region.current.name # <-- update value here
  }
}