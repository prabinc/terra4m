locals {
  common_tags = {
    Environment = terraform.workspace
    Project     = "${var.project}"
    Application = "${var.application}"
    ManagedBy   = "Terraform"
  }
}
resource "aws_security_group" "bastion-sg" {
  tags = merge(
    local.common_tags,
    tomap({ "Name" = "${var.prefix}b-sg" })
  )
  vpc_id      = var.vpc_id
  description = "Bastion open to internet"

  lifecycle {
    create_before_destroy = true
  }
}
resource "aws_security_group_rule" "bastion-sg-ingress-rule" {
  type              = "ingress"
  from_port         = var.bastion_ssh_port
  to_port           = var.bastion_ssh_port
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.bastion-sg.id
}
resource "aws_security_group_rule" "basition-sg-egress-rule" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.bastion-sg.id
}

resource "aws_security_group" "controller-node-sg" {
  tags = merge(
    local.common_tags,
    tomap({ "Name" = "${var.prefix}c-sg" })
  )
  vpc_id      = var.vpc_id
  description = "Bastion to controller node"

  lifecycle {
    create_before_destroy = true
  }
}
resource "aws_security_group_rule" "controller-node-sg-ingress-rule" {
  type                     = "ingress"
  from_port                = var.bastion_ssh_port
  to_port                  = var.bastion_ssh_port
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.bastion-sg.id
  security_group_id        = aws_security_group.controller-node-sg.id
}
resource "aws_security_group_rule" "controller-node-sg-egress-rule" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.controller-node-sg.id
}
resource "aws_security_group" "cluster-sg" {
  tags = merge(
    tomap({ "Name" = "${var.prefix}cl-sg" }),
    local.common_tags
  )
  vpc_id      = var.vpc_id
  description = "intra cluster traffic"

  lifecycle {
    create_before_destroy = true
  }
}
resource "aws_security_group_rule" "cluster-sg-ingress-rule" {
  type              = "ingress"
  from_port         = 0
  to_port           = 0
  protocol          = "tcp"
  cidr_blocks       = ["10.0.16.0/21"]
  security_group_id = aws_security_group.cluster-sg.id
}
resource "aws_security_group_rule" "cluster-sg-egress-rule" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.cluster-sg.id
}

resource "aws_security_group" "jenkins-sg" {
  tags = merge(
    tomap({ "Name" = "${var.prefix}cl-sg" }),
    local.common_tags
  )
  vpc_id      = var.vpc_id
  description = "jenkins node security group"

  lifecycle {
    create_before_destroy = true
  }
}
resource "aws_security_group_rule" "jenkins-ingress-8080" {
  type              = "ingress"
  from_port         = 8080
  to_port           = 8080
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.jenkins-sg.id
}
resource "aws_security_group_rule" "jenkins-ingress-443" {
  type              = "ingress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.jenkins-sg.id
}
resource "aws_security_group_rule" "jenkins-ingress-22122" {
  type              = "ingress"
  from_port         = 22122
  to_port           = 22122
  protocol          = "tcp"
  source_security_group_id = aws_security_group.bastion-sg.id
  security_group_id = aws_security_group.jenkins-sg.id
}
resource "aws_security_group_rule" "jenkins-ingress-22" {
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  source_security_group_id = aws_security_group.bastion-sg.id
  security_group_id = aws_security_group.jenkins-sg.id
}
resource "aws_security_group_rule" "jenkins-egress" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.jenkins-sg.id
}

#####################################################################
##### security groups for EKS    ######################
#####################################################################
