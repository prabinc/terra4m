variable "prefix" {
    description = "prefix will be add in the front of resource name"
}

variable "project" {
    description = "name of the project"
}

variable "application" {
    description = "name of the application"
}

variable "vpc_id" {
  description = "The VPC ID in which to create the security groups."
}

variable "vpc_cidr" {
  description = "The cidr block to use for internal security groups"
}
