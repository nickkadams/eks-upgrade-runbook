# Cleanup pull request (PR)

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

2. Delete all original files `*.orig`

```shell
~ rm -f *.orig
```

3. Delete all markdown files `*.md`

```shell
~ rm -f *.md
```

4. Rename `eks-to-v20.tf` to `eks-on-v17.tf`

```shell
~ mv eks-to-v20.tf eks-on-v17.tf
```

5. Confirm `terraform plan` matches state

```shell
~ terraform plan
No changes. Your infrastructure matches the configuration.
```

## Next [Update node-groups](README.md#final-aws-upgrade-steps)
