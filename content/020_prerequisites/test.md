---
title: "Test the Cluster"
date: 2018-08-07T13:36:57-07:00
weight: 33
---
#### Test the cluster:
Confirm your nodes:

```bash
kubectl get nodes # if we see our 4 nodes, we know we have authenticated correctly
```

#### Update the kubeconfig file to interact with you cluster:
```bash
aws eks update-kubeconfig --name eksworkshop-eksctl --region ${AWS_REGION}
```

#### Congratulations!

You now have a fully working Amazon EKS Cluster that is ready to use!
