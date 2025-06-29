locals {
  name = "cluster1"
}

data "aws_partition" "current" {}

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 17.0"

  cluster_name    = local.name
  cluster_version = var.cluster_version

  vpc_id  = data.terraform_remote_state.vpc.outputs.vpc_id
  subnets = flatten(data.terraform_remote_state.vpc.outputs.private_subnets)

  cluster_endpoint_private_access      = true
  cluster_endpoint_public_access       = true
  cluster_endpoint_public_access_cidrs = var.cluster_endpoint_public_access_cidrs

  write_kubeconfig = false

  # AWS Auth (kubernetes_config_map)
  map_roles = [
    {
      rolearn  = "arn:${data.aws_partition.current.partition}:iam::${var.aws_account_id}:role/${var.aws_assume_role}"
      username = "org-admin"
      groups   = ["system:masters"]
    }
  ]

  map_users = [
    {
      userarn  = "arn:${data.aws_partition.current.partition}:iam::${var.aws_account_id}:user/user1"
      username = "user1"
      groups   = ["system:masters"]
    }
  ]

  node_groups_defaults = {
    ami_type  = "AL2023_x86_64_STANDARD"
    disk_size = var.data_volume_size
  }
}

resource "aws_iam_role_policy_attachment" "ssm" {
  role       = module.eks.worker_iam_role_name
  policy_arn = "arn:${data.aws_partition.current.partition}:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_role_policy_attachment" "ebs" {
  role       = module.eks.worker_iam_role_name
  policy_arn = "arn:${data.aws_partition.current.partition}:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
}
