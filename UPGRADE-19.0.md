# Upgrade from v18.x to v19.x

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

2. Rename `eks-to-v18.tf` to `eks-to-v18.tf.orig`

```shell
~ mv eks-to-v18.tf eks-to-v18.tf.orig
```

3. Rename `karpenter.tf` to `karpenter.tf.orig`

```shell
~ mv karpenter.tf karpenter.tf.orig
```

4. Rename `karpenter.tf.upgrade` to `karpenter.tf`

```shell
~ mv karpenter.tf.upgrade karpenter.tf
```

5. Rename `eks-to-v19.tf.upgrade` to `eks-to-v19.tf`

```shell
~ mv eks-to-v19.tf.upgrade eks-to-v19.tf
```

6. Confirm module and base configuration looks correct in `eks-to-v19.tf`

```hcl
module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 19.0"

  cluster_name    = local.name
  cluster_version = var.cluster_version
  # ...
}
```

7. Initialize v19 of the eks module:

```shell
~ terraform init -upgrade=true
Initializing the backend...
Upgrading modules...
Downloading registry.terraform.io/terraform-aws-modules/eks/aws 19.21.0 for eks...
```

8. Final steps:

```shell
~ terraform plan
Plan: 14 to add, 5 to change, 8 to destroy.

~ terraform apply
Modifications complete after 18m5s
Apply complete! Resources: 14 added, 5 changed, 8 destroyed.
```

- Features
  - Envelope encryption
  - IAM access entry for Karpenter

## Next [Upgrade to v20.x](UPGRADE-20.0.md)
