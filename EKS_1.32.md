# Upgrade from EKS 1.31 to 1.32

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

2. Confirm karpenter is running version >= 1.2

```shell
~ kubectl get deployments/karpenter -n kube-system -o jsonpath="{..image}"
public.ecr.aws/karpenter/controller:1.4.0@sha256:e39215600820529c25a119b95f7431dcc103834766426b2beb48f87fa87555bb%

~ for crd in `kubectl get crd | grep karpenter | awk '{print $1}'`; do kubectl get crd $crd -o yaml | grep \/version:; done
    controller-gen.kubebuilder.io/version: v0.17.3
    controller-gen.kubebuilder.io/version: v0.17.3
    controller-gen.kubebuilder.io/version: v0.17.3
```

3. Update `variables.tf`

```hcl
variable "cluster_version" {
  type        = string
  default     = "1.32"
  # ...
}
```

4. Final steps:

```shell
~ terraform plan
Plan: 1 to add, 2 to change, 1 to destroy.

~ terraform apply
Apply complete! Resources: 1 added, 1 changed, 1 destroyed.
Modifications complete after 8m4s
```

- Features
  - Kubernetes version 1.32
