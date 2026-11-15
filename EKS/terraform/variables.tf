variable "region" {
  description = "AWS region to deploy into"
  type        = string
  default     = "us-east-1"
}

variable "cluster_name" {
  description = "Name of the EKS cluster (also used to name the VPC and IAM roles)"
  type        = string
  default     = "demo-eks"
}

variable "kubernetes_version" {
  description = "Kubernetes version of the control plane"
  type        = string
  default     = "1.35"
}

variable "vpc_cidr" {
  description = "IP range of the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "node_instance_type" {
  description = "EC2 size of every worker node"
  type        = string
  default     = "t3.medium"
}

variable "node_min_size" {
  description = "Fewest worker nodes the node group may shrink to"
  type        = number
  default     = 1
}

variable "node_desired_size" {
  description = "Worker nodes created at the start"
  type        = number
  default     = 2
}

variable "node_max_size" {
  description = "Most worker nodes the node group may grow to"
  type        = number
  default     = 4
}
