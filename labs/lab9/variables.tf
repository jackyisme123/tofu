variable "environment" {
  description = "Environment name for resource naming and tagging"
  type        = string
  default     = "production"
}

variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
  default     = "172.16.0.0/16"
}

variable "subnet_cidr" {
  description = "CIDR block for subnet"
  type        = string
  default     = "172.16.1.0/24"
}

variable "project_name" {
  description = "Project name for resource tagging"
  type        = string
  default     = "dynamic-infrastructure"
}

variable "subnet_count" {
  description = "Number of subnets to create"
  type        = number
  default     = 2
}

variable "route_table_count" {
  description = "Number of route tables to create"
  type        = number
  default     = 2
}

variable "availability_zones" {
  description = "Availability zones for subnets"
  type        = list(string)
  default     = ["ap-southeast-2a", "ap-southeast-2b", "ap-southeast-2c"]
}

variable "subnet_config" {
  description = "Map of subnet configurations"
  type        = map(string)
  default = {
    "public"   = "172.16.10.0/24"
    "private1" = "172.16.11.0/24"
    # "private2" = "172.16.3.0/24"
  }
}

variable "subnet_azs" {
  description = "Map of subnet availability zones"
  type        = map(string)
  default = {
    "public"   = "ap-southeast-2a"
    "private1" = "ap-southeast-2b"
    # "private2" = "ap-southeast-2c"
  }
}

variable "subnet_cidr_blocks" {
  description = "CIDR blocks for subnets"
  type        = list(string)
  default     = ["172.16.1.0/24", "172.16.2.0/24", "172.16.3.0/24"]
}

variable "security_groups" {
  description = "Security group configurations"
  type = list(object({
    name         = string
    description  = string
    ingress_port = number
  }))
  default = [
    {
      name         = "web"
      description  = "Allow web traffic"
      ingress_port = 80
    },
    {
      name         = "app"
      description  = "Allow application traffic"
      ingress_port = 8080
    },
    {
      name         = "db"
      description  = "Allow database traffic"
      ingress_port = 3306
    }
  ]
}


variable "route_tables" {
  description = "Map of route tables to create"
  type        = map(string)
  default = {
    "public"   = "Public route table"
    "private1" = "Private route table 1"
    "private2" = "Private route table 2"
  }
}

variable "security_group_config" {
  description = "Map of security group ports"
  type        = map(number)
  default = {
    "web"   = 80
    "app"   = 8080
    "db"    = 3306
    "cache" = 6379  # Added new entry
  }
}
