data "aws_ssm_parameter" "eksami" {
  name=format("/aws/service/eks/optimized-ami/%s/amazon-linux-2/recommended/image_id", aws_eks_cluster.main.version)
}



