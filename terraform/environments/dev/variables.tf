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
