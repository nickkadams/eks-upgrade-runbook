# Upgrade from v17.x to v18.x

## Steps

1. Confirm kubectl access to `cluster1`

```shell
~ export AWS_PROFILE=standard
~ aws sso login --profile standard
~ kubectl cluster-info
# If required, update your ~/.kube/config
~ aws eks --profile standard --region us-east-1 update-kubeconfig --name cluster1 --alias cluster1
~ export KUBE_CONFIG_PATH=~/.kube/config
```

2. Confirm a recent velero backup of `cluster1` exists.

```shell
~ velero backup describe cluster1-20250628 --details
~ velero backup logs cluster1-20250628
~ aws s3 ls s3://velero-backups-012345678901/backups/cluster1-20250628/
# If required, create one
~ velero backup create cluster1-20250628 --include-namespaces '*' --snapshot-volumes --ttl 168h0m0s
```

3. Backup current terraform state.

```shell
~ mkdir ~/Desktop/cluster1
~ terraform state list > ~/Desktop/cluster1/terraform_state.txt
~ cat ~/Desktop/cluster1/terraform_state.txt
```

4. Backup current aws-auth ConfigMap.

```shell
~ kubectl describe -n kube-system configmap/aws-auth > ~/Desktop/cluster1/aws-auth.txt
~ cat ~/Desktop/cluster1/aws-auth.txt
```

5. If required, update the AWS Console EKS Cluster > Access > Manage access  to **EKS API and ConfigMap**. Confirm Status is Successful under Update history.
6. Run `terraform plan` with the module version [v17.24.0](https://github.com/terraform-aws-modules/terraform-aws-eks/releases/tag/v17.24.0)
7. Rename `eks-on-v17.tf` to `eks-on-v17.tf.orig`

```shell
~ mv eks-on-v17.tf eks-on-v17.tf.orig
```

8. Rename `aws-auth.tf` to `aws-auth.tf.orig`

```shell
~ mv aws-auth.tf aws-auth.tf.orig
```

9. Rename `eks-to-v18.tf.upgrade` to `eks-to-v18.tf`

```shell
~ mv eks-to-v18.tf.upgrade eks-to-v18.tf
```

10. Confirm module and base configuration looks correct in `eks-to-v18.tf`

```hcl
module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 18.0"

  cluster_name    = local.name
  cluster_version = var.cluster_version
  # ...

  # prefix_separator                   = ""
  # iam_role_name                      = local.name
  # cluster_security_group_name        = local.name
  # cluster_security_group_description = "EKS cluster security group."

  # ...  
}
```

11. Initialize v18 of the eks module:

```shell
~ terraform init -upgrade=true
Initializing the backend...
Upgrading modules...
Downloading registry.terraform.io/terraform-aws-modules/eks/aws 18.31.2 for eks...
```

12. Uncomment below in `eks-to-v18.tf`

```hcl
module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 18.0"

  cluster_name    = local.name
  cluster_version = var.cluster_version
  # ...

  # Uncomment below
  prefix_separator                   = ""
  iam_role_name                      = local.name
  cluster_security_group_name        = local.name
  cluster_security_group_description = "EKS cluster security group."

  # ...  
}
```

13. **WARNING:** DO NOT run `terraform plan` before moving state for the iam role:

```shell
~ terraform state mv 'module.eks.aws_iam_role.cluster[0]' 'module.eks.aws_iam_role.this[0]'
Move "module.eks.aws_iam_role.cluster[0]" to "module.eks.aws_iam_role.this[0]"
Successfully moved 1 object(s).
```

14. Now you can run `terraform plan`:

```shell
~ terraform plan
...
Plan: 21 to add, 4 to change, 16 to destroy.
```

15. Run target based terraform applies in the specificed order:

```shell
~ terraform apply -target 'module.eks.aws_iam_role.this[0]'
~ terraform apply -target 'module.eks.aws_eks_cluster.this[0]'
~ terraform apply -target 'module.eks.aws_eks_cluster.this[0]' -refresh-only
```

16. **WARNING:** confirm you backed up the `aws-auth` ConfigMap in step 5 and that your `aws_auth_roles` block is accurate.

```shell
~ terraform apply -target 'module.eks.kubernetes_config_map.aws_auth[0]'
```

17. If the resources below exist in your terraform state, run target based removes in the specified order:

```shell
~ terraform state rm 'module.eks.aws_iam_role_policy_attachment.workers_AmazonEKS_CNI_Policy[0]'
~ terraform state rm 'module.eks.aws_iam_role_policy_attachment.workers_AmazonEKSWorkerNodePolicy[0]'
~ terraform state rm 'module.eks.aws_iam_role_policy_attachment.workers_AmazonEC2ContainerRegistryReadOnly[0]'
```

18. Run additional target based terraform state removes in the specificed order:

```shell
~ terraform state rm 'module.eks.aws_security_group.workers[0]'
~ terraform state rm 'module.eks.aws_security_group_rule.workers_ingress_self[0]'
~ terraform state rm 'module.eks.aws_security_group_rule.workers_ingress_cluster_https[0]'
~ terraform state rm 'module.eks.aws_security_group_rule.workers_ingress_cluster[0]'
~ terraform state rm 'module.eks.aws_security_group_rule.workers_egress_internet[0]'
~ terraform state rm 'module.eks.aws_security_group_rule.cluster_https_worker_ingress[0]'
~ terraform state rm 'module.eks.aws_security_group_rule.cluster_egress_internet[0]'
```

19. Final steps:

```shell
~ terraform plan
Plan: 5 to add, 1 to change, 9 to destroy.

~ terraform apply
Apply complete! Resources: 5 added, 1 changed, 9 destroyed.
```

- Features
  - Authentication mode - EKS API and ConfigMap

- Source [clowdhaus](https://github.com/clowdhaus/eks-v17-v18-migrate)

## Next [Upgrade to v19.x](UPGRADE-19.0.md)
