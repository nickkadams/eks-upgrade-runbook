# Upgrade from v19.x to v20.x

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

2. Rename `eks-to-v19.tf` to `eks-to-v19.tf.orig`

```shell
~ mv eks-to-v19.tf eks-to-v19.tf.orig
```

3. Rename `eks-to-v20.tf.upgrade` to `eks-to-v20.tf`

```shell
~ mv eks-to-v20.tf.upgrade eks-to-v20.tf
```

4. Confirm module and base configuration looks correct in `eks-to-v20.tf`

```hcl
module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.0"

  cluster_name    = local.name
  cluster_version = var.cluster_version
  # ...
  
  authentication_mode = "API"
  # ...
}
```

5. Initialize v20 of the eks and eks_aws_auth module:

```shell
~ terraform init -upgrade=true
Initializing the backend...
Upgrading modules...
Downloading registry.terraform.io/terraform-aws-modules/eks/aws 20.36.0 for eks...
Downloading registry.terraform.io/terraform-aws-modules/eks/aws 20.36.0 for eks_aws_auth...
```

6. If the resources below exist in your terraform state, run target based removes in the specified order:

```shell
~ terraform state rm 'module.eks.kubernetes_config_map_v1_data.aws_auth[0]'
~ terraform state rm 'module.eks.kubernetes_config_map.aws_auth[0]'
```

7. Final steps:

```shell
~ terraform plan
Plan: 21 to add, 4 to change, 1 to destroy.

~ terraform apply
Apply complete! Resources: 21 added, 3 changed, 1 destroyed.
```

- Features
  - Authentication mode - EKS API
  - IAM access entries

## Next [Upgrade to Cluster version 1.31](EKS_1.31.md)
