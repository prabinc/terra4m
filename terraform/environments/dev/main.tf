provider "aws" {
  region = "us-east-2"
}


locals {
  prefix = "${var.prefix}-${terraform.workspace}"
  common_tags = {
    Environment = terraform.workspace
    Application = "${var.application}"
    Project     = "${var.project}"
    ManagedBy   = "Terraform"
  }
}

data "aws_region" "current" {}

module "vpc" {
  create_vpc          = true
  source              = "../../modules/aws-vpc"
  cidr_block          = "10.0.16.0/21"
  azs                 = ["us-east-2a", "us-east-2b", "us-east-2c", "us-east-2a", "us-east-2b"]
  public_subnet_cidr  = ["10.0.16.128/25", "10.0.17.0/25", "10.0.17.128/25"]
  private_subnet_cidr = ["10.0.19.0/24", "10.0.20.0/24", "10.0.21.0/24", "10.0.22.0/24"]
  db_subnet_cidr      = ["10.0.16.0/27", "10.0.16.32/27", "10.0.16.64/27"]
  extra_subnet_cidr   = ["10.0.18.0/24"]
  enable_nat_gateway  = true
  public_eks_tag      = var.public_eks_tag
  private_eks_tag     = var.private_eks_tag
  prefix              = var.prefix
  project             = var.project
  application         = var.application
  eks_cluster_name    = var.prefix
}

module "sg" {
  source      = "../../modules/sg"
  vpc_cidr    = module.vpc.vpc_cidr
  vpc_id      = module.vpc.vpc_id
  prefix      = var.prefix
  project     = var.project
  application = var.application

}

module "eks" {
  source                  = "../../modules/eks"
  cluster_name            = var.prefix
  k8s_version             = "1.20"
  node_instance_type      = "t3.medium"
  desired_capacity        = 2
  max_size                = 2
  min_size                = 1
  vpc_id                  = module.vpc.vpc_id
  vpc_cidr                = module.vpc.vpc_cidr
  endpoint_private_access = true
  endpoint_public_access  = true
  subnet_ids              = module.vpc.subnet_ids
  private_subnets         = module.vpc.private_subnets
  vpc_subnet_cidr         = module.vpc.vpc_cidr
  private_subnet_cidr     = module.vpc.private_subnets_cidr_blocks
  public_subnet_cidr      = module.vpc.public_subnets_cidr_blocks
  db_subnet_cidr          = module.vpc.db_subnets_cidr_blocks
  eks_cw_logging          = ["api", "audit", "authenticator", "controllerManager", "scheduler"]
  prefix                  = var.prefix
  project                 = var.project
  application             = var.application
}

