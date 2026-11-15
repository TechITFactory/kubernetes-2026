output "cluster_name" {
  value = module.eks.cluster_name
}

output "cluster_endpoint" {
  value = module.eks.cluster_endpoint
}

output "region" {
  value = var.region
}

output "developer_role_arn" {
  value = aws_iam_role.developer.arn
}

output "developers_group" {
  value = aws_iam_group.developers.name
}

output "connect_command" {
  value = "aws eks update-kubeconfig --region ${var.region} --name ${module.eks.cluster_name}"
}
