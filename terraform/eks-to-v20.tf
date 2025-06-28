locals {
  name = "cluster1"
}

data "aws_partition" "current" {}

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.0"

  cluster_name    = local.name
  cluster_version = var.cluster_version

  cluster_endpoint_public_access       = var.cluster_endpoint_public_access
  cluster_endpoint_public_access_cidrs = var.cluster_endpoint_public_access_cidrs

  iam_role_name            = "cluster-${local.name}"
  iam_role_use_name_prefix = false

  cluster_encryption_policy_name            = "cluster-encryption-${local.name}"
  cluster_encryption_policy_use_name_prefix = false

  kms_key_deletion_window_in_days = 7

  cluster_security_group_additional_rules = var.cluster_security_group_additional_rules
  cluster_security_group_use_name_prefix  = false

  node_security_group_additional_rules = var.node_security_group_additional_rules
  node_security_group_use_name_prefix  = false

  authentication_mode = var.authentication_mode

  enable_cluster_creator_admin_permissions = var.enable_cluster_creator_admin_permissions

  cluster_addons = {
    vpc-cni = {
      most_recent              = true
      before_compute           = true
      service_account_role_arn = module.vpc_cni_irsa.iam_role_arn
      configuration_values = jsonencode({
        enableNetworkPolicy = "true"
        env = {
          # Ref https://docs.aws.amazon.com/eks/latest/userguide/cni-increase-ip-addresses.html
          ENABLE_PREFIX_DELEGATION = "true"
          WARM_PREFIX_TARGET       = "1"
        }
      })
    }
    kube-proxy = {
      most_recent = true
    }
    coredns = {
      most_recent = true
    }
    eks-pod-identity-agent = {
      most_recent    = true
      before_compute = true
    }
    aws-ebs-csi-driver = {
      most_recent              = true
      service_account_role_arn = module.ebs_csi_driver_irsa.iam_role_arn
      configuration_values = jsonencode({
        node = {
          # Ref https://stackoverflow.com/questions/78932976/how-do-i-configure-the-terraform-aws-eks-addon-aws-ebs-csi-driver-volumeattachli
          volumeAttachLimit = var.max_volumes_attached
        }
      })
    }
    snapshot-controller = {
      most_recent = true
    }
  }

  vpc_id     = data.terraform_remote_state.vpc.outputs.vpc_id
  subnet_ids = flatten(data.terraform_remote_state.vpc.outputs.private_subnets)

  eks_managed_node_group_defaults = {
    ami_type       = "AL2023_x86_64_STANDARD"
    instance_types = var.node_group_instance_types

    iam_role_additional_policies = {
      AmazonSSMManagedInstanceCore = "arn:${data.aws_partition.current.partition}:iam::aws:policy/AmazonSSMManagedInstanceCore",
      AmazonEBSCSIDriverPolicy     = "arn:${data.aws_partition.current.partition}:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
    }
  }
}
