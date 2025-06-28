# Upgrade from EKS 1.30 to 1.31

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

2. Update `variables.tf`

```hcl
variable "kubernetes-version" {
  type        = string
  default     = "1.31"
  # ...
}
```

3. Final steps:

```shell
~ terraform plan
Plan: 1 to add, 2 to change, 1 to destroy.

~ terraform apply
Apply complete! Resources: 1 added, 1 changed, 1 destroyed.
Modifications complete after 6m42s
```

- Features
  - Kubernetes version 1.31
