variable "prefix" {
  default = "awsmodmvnkqp"
}
variable "project" {
  default = "maven-modernization"
}
variable "application" {
  type    = string
  default = "awsmodmvnkqp"
}
variable "public_eks_tag" {
  description = "tag needed for eks"
  type        = map(any)
  default     = { "kubernetes.io/role/elb" = 1 }
}
variable "private_eks_tag" {
  description = "tag needed for eks"
  type        = map(any)
  default     = { "kubernetes.io/role/internal-elb" = 1 }
}

variable "bastion_ami" {
  description = "ami id for bastion server"
  default     = ""
}

variable "controller_ami" {
  description = "ami id for eks controller node"
  default     = ""
}

variable "jenkins_ami" {
  description = "ami id for jenkins node"
  default     = ""
}

