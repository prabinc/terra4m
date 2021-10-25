
resource "aws_eks_addon" "vpc-cni" {
#  depends_on   = [aws_eks_node_group.eks-node-group]
  cluster_name = aws_eks_cluster.main.name
  addon_name   = "vpc-cni"
}

resource "aws_eks_addon" "kube-proxy" {
#  depends_on   = [aws_eks_node_group.eks-node-group]
  cluster_name = aws_eks_cluster.main.name
  addon_name   = "kube-proxy"
}

resource "aws_eks_addon" "coredns" {
#  depends_on   = [aws_eks_node_group.eks-node-group]
  cluster_name = aws_eks_cluster.main.name
  addon_name   = "coredns"
}


############### NODE GROUP CONFIGS ####################

resource "aws_eks_node_group" "eks-node-group" {
  cluster_name    = var.cluster_name
  node_group_name = "${var.cluster_name}_default_node_group"
  node_role_arn   = aws_iam_role.node.arn
  subnet_ids      = var.private_subnets

  # Ensure that IAM Role permissions are created before and deleted after EKS Node Group handling.
  # Otherwise, EKS will not be able to properly delete EC2 Instances and Elastic Network Interfaces.
  depends_on = [
    aws_eks_cluster.main,
    aws_launch_template.lt-eks-ng,
    aws_iam_role_policy_attachment.node-AmazonEKSWorkerNodePolicy,
    aws_iam_role_policy_attachment.node-AmazonEKS_CNI_Policy
  ]

  scaling_config {
    desired_size = var.desired_capacity
    max_size     = var.max_size
    min_size     = var.min_size
  }

  launch_template {
    name = aws_launch_template.lt-eks-ng.name
    version = aws_launch_template.lt-eks-ng.latest_version
  }
  remote_access {
    
  }
  # instance_types = []   #will be set in the launch template

  #kubernetes labels
  labels = {
    "eks/cluster-name"   = aws_eks_cluster.main.name
    "eks/nodegroup-name" = format("eks-ng-%s", aws_eks_cluster.main.name)
  }



  tags = {
    "eks/cluster-name"                            = aws_eks_cluster.main.name
    "eks/eksctl-version"                          = "0.29.2"
    "eks/nodegroup-name"                          = format("ng1-%s", aws_eks_cluster.main.name)
    "eks/nodegroup-type"                          = "managed"
    "eksctl.cluster.k8s.io/v1alpha1/cluster-name" = aws_eks_cluster.main.name
    "Name"                                        = "${var.prefix}"
    "Environment"                                 = terraform.workspace
    "Project"                                     = "${var.project}"
    "Application"                                 = "${var.application}"
    "ManagedBy"                                   = "Terraform"
  }

  lifecycle {
    ignore_changes = [scaling_config[0].desired_size]
  }

  timeouts {}
}