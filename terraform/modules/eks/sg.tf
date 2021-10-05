### Security Groups

# CLUSTER SECURITY GROUPS
#need a cluster sec group which allows traffic within the cluster, source is VPC cidr

resource "aws_security_group" "cluster-sg" {
  description = "communication between the control plane and worker nodes"
  vpc_id      = var.vpc_id
  tags = merge(
    local.common_tags,
    tomap({ "Name" = "${var.prefix}" })
  )
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_security_group" "node-sg" {
  description = "Communication between all nodes within the cluster"
  vpc_id      = var.vpc_id
  tags = merge(
    local.common_tags,
    tomap({ "Name" = "${var.prefix}" })
  )
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_security_group_rule" "eks-all" {
  type              = "ingress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.cluster-sg.id
}

resource "aws_security_group_rule" "eks-all-egress" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  security_group_id = aws_security_group.cluster-sg.id
  cidr_blocks       = ["0.0.0.0/0"]
}


resource "aws_security_group_rule" "eks-node" {
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = [var.vpc_cidr]
  security_group_id = aws_security_group.node-sg.id
}


resource "aws_security_group_rule" "eks-node-egress" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  security_group_id = aws_security_group.node-sg.id
  cidr_blocks       = ["0.0.0.0/0"]
}


resource "aws_security_group_rule" "eks-all-node" {
  type                     = "ingress"
  from_port                = 0
  to_port                  = 0
  protocol                 = "-1"
  source_security_group_id = aws_security_group.node-sg.id
  security_group_id        = aws_security_group.cluster-sg.id
}

resource "aws_security_group_rule" "eks-node-all" {
  type                     = "ingress"
  from_port                = 0
  to_port                  = 0
  protocol                 = "-1"
  source_security_group_id = aws_security_group.cluster-sg.id
  security_group_id        = aws_security_group.node-sg.id
}

resource "aws_security_group_rule" "eks-all-self" {
  type              = "ingress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  self              = true
  security_group_id = aws_security_group.cluster-sg.id
}

resource "aws_security_group_rule" "eks-node-self" {
  type              = "ingress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  self              = true
  security_group_id = aws_security_group.node-sg.id
}
###########################################################################################
############### using sg module #########################################################
# module "cluster-sg" {
#   source  = "terraform-aws-modules/security-group/aws"
#   version = "4.2.0"

#   name        = "cluster-sg"
#   description = "EKS node security groups"
#   vpc_id      = var.vpc_id

#   ingress_cidr_blocks = ["0.0.0.0/0"]

#   computed_ingress_with_source_security_group_id = [
#     {
#       from_port                = 443
#       to_port                  = 443
#       protocol                 = "tcp"
#       description              = "Allow pods to communicate with the cluster API Server"
#       source_security_group_id = module.node-sg.security_group_id
#     },
#   ]

#   number_of_computed_ingress_with_source_security_group_id = 1

#   egress_cidr_blocks = ["0.0.0.0/0"]
#   egress_rules       = ["all-all"]

#   tags = {
#     Name = "${var.cluster_name}-eks-cluster-sg"
#   }
# }

# # NODES SECURITY GROUPS

# module "node-sg" {
#   source  = "terraform-aws-modules/security-group/aws"
#   version = "4.2.0"

#   name        = "node-sg"
#   description = "EKS node security groups"
#   vpc_id      = var.vpc_id

#   ingress_cidr_blocks = [var.vpc_cidr]
#   ingress_with_self = [
#     {
#       rule = "all-all"
#     },
#   ]
#   computed_ingress_with_source_security_group_id = [
#     {
#       from_port                = 1025
#       to_port                  = 65535
#       protocol                 = "tcp"
#       description              = "Allow EKS Control Plane"
#       source_security_group_id = module.cluster-sg.security_group_id
#     },
#   ]

#   number_of_computed_ingress_with_source_security_group_id = 1

#   egress_cidr_blocks = ["0.0.0.0/0"]
#   egress_rules       = ["all-all"]

#   tags = {
#     Name                                        = "${var.cluster_name}-eks-node-sg"
#     "kubernetes.io/cluster/${var.cluster_name}" = "owned"
#   }
# }
