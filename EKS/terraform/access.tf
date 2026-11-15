data "aws_caller_identity" "current" {}

# 1. The IAM role every developer will assume to reach the cluster
resource "aws_iam_role" "developer" {
  name = "${var.cluster_name}-developer"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Action    = "sts:AssumeRole"
      Principal = { AWS = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root" }
    }]
  })
}

# 2. A group: adding a person to it is the whole onboarding step
resource "aws_iam_group" "developers" {
  name = "${var.cluster_name}-developers"
}

# 3. The group may assume the role and look the cluster up (needed for "aws eks update-kubeconfig")
resource "aws_iam_group_policy" "developers" {
  name  = "eks-access"
  group = aws_iam_group.developers.name

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = "sts:AssumeRole"
        Resource = aws_iam_role.developer.arn
      },
      {
        Effect   = "Allow"
        Action   = ["eks:DescribeCluster", "eks:ListClusters"]
        Resource = "*"
      }
    ]
  })
}
