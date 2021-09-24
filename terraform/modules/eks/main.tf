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
    subnet_ids         = var.subnet_ids
    endpoint_private_access = var.endpoint_private_access
    endpoint_public_access = var.endpoint_public_access
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


############### NODE GROUP CONFIGS ####################

resource "aws_eks_node_group" "eks-node-group" {
  cluster_name    = var.cluster_name
  node_group_name = "${var.cluster_name}_default_node_group"
  node_role_arn   = aws_iam_role.node.arn
  subnet_ids      = var.private_subnets
  
  scaling_config {
    desired_size = var.desired_capacity
    max_size     = var.max_size
    min_size     = var.min_size
  }
  lifecycle {
    ignore_changes = [scaling_config[0].desired_size]
  }

  instance_types = [var.node_instance_type]

  #kubernetes labels
  labels = {
    role = "eks-worker-node"
  }
  # Ensure that IAM Role permissions are created before and deleted after EKS Node Group handling.
  # Otherwise, EKS will not be able to properly delete EC2 Instances and Elastic Network Interfaces.
  depends_on = [
    aws_eks_cluster.main,
    aws_iam_role_policy_attachment.node-AmazonEKSWorkerNodePolicy,
    aws_iam_role_policy_attachment.node-AmazonEKS_CNI_Policy
  ]
  tags = merge(
    local.common_tags,
    tomap({ "Name" = "${var.prefix}-ng" })
  )
}
