module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 21.0"

  name               = var.cluster_name
  kubernetes_version = var.kubernetes_version

  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnets

  # API server reachable from your laptop. Production: restrict the CIDRs or use private only.
  endpoint_public_access = true

  # Access is managed with EKS access entries (no aws-auth ConfigMap)
  authentication_mode = "API"

  # Whoever runs terraform becomes cluster admin
  enable_cluster_creator_admin_permissions = true

  # Core add-ons, installed and kept up to date by AWS
  addons = {
    coredns                = {}
    kube-proxy             = {}
    vpc-cni                = { before_compute = true }
    eks-pod-identity-agent = { before_compute = true }
    metrics-server         = {}
  }

  # The worker nodes: an AWS-managed Auto Scaling group of EC2 instances
  eks_managed_node_groups = {
    default = {
      ami_type       = "AL2023_x86_64_STANDARD"
      instance_types = [var.node_instance_type]
      capacity_type  = "ON_DEMAND"

      min_size     = var.node_min_size
      desired_size = var.node_desired_size
      max_size     = var.node_max_size

      disk_size = 20
      labels    = { workload = "general" }
    }
  }

  # Pods on different nodes must reach each other on any port.
  # The module only opens ports 1025-65535 between nodes by default, so a Service on port 80 would time out.
  node_security_group_additional_rules = {
    ingress_self_all = {
      description = "Node to node, all ports and protocols"
      protocol    = "-1"
      from_port   = 0
      to_port     = 0
      type        = "ingress"
      self        = true
    }
  }

  # Extra people who may use the cluster (see access.tf for the role)
  access_entries = {
    developer = {
      principal_arn = aws_iam_role.developer.arn

      policy_associations = {
        # Read everything in the cluster
        view_all = {
          policy_arn   = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSViewPolicy"
          access_scope = { type = "cluster" }
        }
        # Change things only in the "dev" namespace
        edit_dev = {
          policy_arn   = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSEditPolicy"
          access_scope = { type = "namespace", namespaces = ["dev"] }
        }
      }
    }
  }
}
