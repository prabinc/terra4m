variable "prefix" {
  default = "prefix"
}

variable "project" {
  default = "project_name"
}
variable "application" { 
  default = "application"
}

variable "create_vpc" {
  description = "Controls if VPC should be created (it affects almost all resources)"
  type        = bool
  default     = true
}
variable "cidr_block" {
  description = "Enter the CIDR block you want to use for the project"
  type = string
  default = "10.0.0.0/16"
}
variable "azs" {
  description = "A list of availability zones names or ids in the region"
  type        = list(string)
  default     = []
}

variable "public_subnet_cidr" {
  default = ["10.0.8.128/25", "10.0.9.0/25", "10.0.9.128/25"]
  type    = list(any)
}

variable "private_subnet_cidr" {
  description = "Enter a list of private subnets"
  type    = list(any)
}
variable "db_subnet_cidr" {
  description = "Enter a list of db subnets"
  type    = list(any)
}

variable "enable_nat_gateway" {
  description = "Should be true if you want to provision NAT Gateways for each of your private networks"
  type        = bool
  default     = false
}

variable "public_eks_tag" {
  description = "tag needed for eks"
  type = map
  default = {"kubernetes.io/role/elb" = 1}
}
variable "private_eks_tag" {
  description = "tag needed for eks"
  type = map
  default = {"kubernetes.io/role/internal-elb" = 1}
}
