
#################### bastion server  ####################

resource "aws_instance" "bastion" {
  count                       = 0
  ami                         = var.bastion_ami
  instance_type               = "t2.micro"
  subnet_id                   = element(module.vpc.public_subnets, 1)
  associate_public_ip_address = true
  vpc_security_group_ids      = [module.sg.bastion-sg]
  key_name                    = "bastion"
  user_data                   = <<-EOF
    #! /bin/bash
    sudo apt update && sudo apt upgrade -y
    reboot now
  EOF

  lifecycle {
    prevent_destroy = true
  }
}

#################### eks controller node  ####################

resource "aws_instance" "controller" {
  count = 0
  ami                         = var.controller_ami
  instance_type               = "t2.micro"
  subnet_id                   = element(module.vpc.private_subnets, 1)
  associate_public_ip_address = false
  vpc_security_group_ids      = [module.sg.controller-node-sg]
  key_name                    = "jenkins"
  user_data                   = <<-EOF
    #! /bin/bash
    sudo apt update && sudo apt upgrade -y 
    reboot now
  EOF

  tags = merge(
    local.common_tags,
    tomap({ "Name" = "${var.prefix}-controller" })
  )
  lifecycle {
    prevent_destroy = false
  }
  depends_on = [module.eks.main]
}

#################### jenkins instance  ####################

resource "aws_instance" "jenkins" {
  count                       = 0
  ami                         = var.jenkins_ami
  instance_type               = "t2.micro"
  subnet_id                   = element(module.vpc.private_subnets, 1)
  associate_public_ip_address = true
  vpc_security_group_ids      = [module.sg.jenkins-sg]
  key_name                    = "jenkins"
  user_data                   = <<-EOF
    #! /bin/bash
    sudo apt update && sudo apt upgrade -y 
    reboot now
  EOF

  lifecycle {
    prevent_destroy = true
  }
}
