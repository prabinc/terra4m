variable "prefix" {
  default = "prefix"
}

variable "project" {
  default = "project_name"
}
variable "application" {
  default = "application"
}
variable "cluster_name" {
  type        = string
  description = "The name of your EKS Cluster"
}
variable "k8s_version" {
  default     = "1.20"
  type        = string
  description = "Required K8s version"
}

variable "kublet_extra_args" {
  default     = ""
  type        = string
  description = "Additional arguments to supply to the node kubelet process"
}

variable "public_kublet_extra_args" {
  default     = ""
  type        = string
  description = "Additional arguments to supply to the public node kubelet process"

}
variable "vpc_id" {
  description = "vpc id - get from vpc module"
}
variable "vpc_cidr" {
  description = "cidr block of the vpc"

}

variable "vpc_subnet_cidr" {
  type        = string
  description = "The VPC Subnet CIDR"
}

variable "private_subnet_cidr" {
  type        = list(any)
  description = "Private Subnet CIDR"
}

variable "public_subnet_cidr" {
  type        = list(any)
  description = "Public Subnet CIDR"
}

variable "db_subnet_cidr" {
  type        = list(any)
  description = "DB/Spare Subnet CIDR"
}

variable "subnet_ids" {
  description = "list of all private and public subnets"
  type        = list(any)
}

variable "private_subnets" {

}

variable "eks_cw_logging" {
  default     = ["api", "audit", "authenticator", "controllerManager", "scheduler"]
  type        = list(any)
  description = "Enable EKS CWL for EKS components"
}

variable "node_instance_type" {
  default     = "m4.large"
  type        = string
  description = "Worker Node EC2 instance type"
}

variable "root_block_size" {
  default     = "20"
  type        = string
  description = "Size of the root EBS block device"

}

variable "desired_capacity" {
  default     = 2
  type        = string
  description = "Autoscaling Desired node capacity"
}

variable "max_size" {
  default     = 5
  type        = string
  description = "Autoscaling maximum node capacity"
}

variable "min_size" {
  default     = 1
  type        = string
  description = "Autoscaling Minimum node capacity"
}

variable "endpoint_private_access" {
  description = "Indicates whether or not the Amazon EKS private API server endpoint is enabled"
}

variable "endpoint_public_access" {
  description = "Indicates whether or not the Amazon EKS public API server endpoint is enabled"
}