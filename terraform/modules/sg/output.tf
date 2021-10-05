output "bastion-sg" {
  value = aws_security_group.bastion-sg.id
}

output "controller-node-sg" {
  value = aws_security_group.controller-node-sg.id
}

output "cluster-sg" {
  value = aws_security_group.cluster-sg.id
}
output "jenkins-sg" {
  value = aws_security_group.jenkins-sg.id
}