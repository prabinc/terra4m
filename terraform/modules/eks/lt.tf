resource "aws_launch_template" "lt-eks-ng" {
  instance_type = "var.node_instance_type"
  
  tag_specifications {
    resource_type = "instance"
    tags = merge(
        local.common_tags,
        tomap({ "Name" = "${var.prefix}" })
        )
    }
  image_id = data.aws_ssm_parameter.eksami.value
  user_data = base64encode(local.eks-node-private-userdata)
  vpc_security_group_ids = [module.node-sg.security_group_id]

  lifecycle {
      create_before_destroy = true
  }

}