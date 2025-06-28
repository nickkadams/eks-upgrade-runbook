# AWS EKS Cluster Upgrade Runbook

## [EKS Module Documentation](https://github.com/terraform-aws-modules/terraform-aws-eks/tree/master/docs#documentation)

- Upgrade Guides
  - [Upgrade to v18.x](UPGRADE-18.0.md)
  - [Upgrade to v19.x](UPGRADE-19.0.md)
  - [Upgrade to v20.x](UPGRADE-20.0.md)
  - [Upgrade to Cluster version 1.31](EKS_1.31.md)
  - [Upgrade to Cluster version 1.32](EKS_1.32.md)
  - [Upgrade to Cluster version 1.33](EKS_1.33.md)
  - [Cleanup pull request (PR)](PR.md)

## [Final AWS Upgrade Steps](https://docs.aws.amazon.com/eks/latest/userguide/update-cluster.html#update-cluster-control-plane)

1. Upgrade the nodes in the [node-groups](./terraform/node-groups/) directory to match the `1.33` control plane.

- Recommended upgrade order (1-2 node-groups at a time)
  - low
  - medium
  - high
  - critical

2. Upgrade the EKS add-ons via AWS Console.
3. Upgrade clients (for example, kubectl).
