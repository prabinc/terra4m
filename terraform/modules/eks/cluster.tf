locals {
  common_tags = {
    Environment = terraform.workspace
    Project     = "${var.project}"
    Application = "${var.application}"
    ManagedBy   = "Terraform"
  }
}

######################  cluster config  ##########################

resource "aws_eks_cluster" "main" {
  name = var.cluster_name

  version = var.k8s_version

  role_arn = aws_iam_role.cluster.arn

  vpc_config {
    #  security_group_ids = [data.aws_security_group.cluster.id]  ## eks might create needed SGs
    subnet_ids              = var.subnet_ids
    endpoint_private_access = var.endpoint_private_access
    endpoint_public_access  = var.endpoint_public_access
  }

  enabled_cluster_log_types = var.eks_cw_logging

  tags = merge(
    local.common_tags,
    tomap({ "Name" = "${var.prefix}" })
  )
  depends_on = [
    aws_iam_role_policy_attachment.cluster-AmazonEKSClusterPolicy,
    aws_iam_role_policy_attachment.cluster-AmazonEKSServicePolicy,
    aws_iam_role_policy_attachment.amazon_eks_vpc_resource_controller,
  ]
}
