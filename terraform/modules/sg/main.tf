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

  ingress {
    from_port   = 22122
    to_port     = 22122
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = -1
    cidr_blocks = ["0.0.0.0/0"]
  }

  lifecycle {
    create_before_destroy = true
  }
}
resource "aws_security_group" "controller-node-sg" {
  tags = merge(
    local.common_tags,
    tomap({ "Name" = "${var.prefix}c-sg" })
  )
  vpc_id      = var.vpc_id
  description = "Bastion to controller node"

  ingress {
    from_port       = 22122
    to_port         = 22122
    protocol        = "tcp"
    security_groups = ["${aws_security_group.bastion-sg.id}"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = -1
    cidr_blocks = ["0.0.0.0/0"]
  }

  lifecycle {
    create_before_destroy = true
  }
}
resource "aws_security_group" "cluster-sg" {
  tags = merge(
    tomap({ "Name" = "${var.prefix}c-sg" }),
    local.common_tags
  )
  vpc_id      = var.vpc_id
  description = "intra cluster traffic"

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = -1
    cidr_blocks = ["${var.vpc_cidr}"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = -1
    cidr_blocks = ["0.0.0.0/0"]
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_security_group" "internal_elb" {
  vpc_id      = var.vpc_id
  description = "Allows internal ELB traffic"

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["${var.vpc_cidr}"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = -1
    cidr_blocks = ["0.0.0.0/0"]
  }

  lifecycle {
    create_before_destroy = true
  }

  tags = merge(
    local.common_tags,
    tomap({ "Name" = "${var.prefix}-internal-elb-sg}" })
  )
}


