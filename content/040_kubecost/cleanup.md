---
title: "Cleanup"
date: 2021-11-07T11:05:19-07:00
weight: 45
draft: false
---

# Cleanup

Congratulations on completing the cost management with Kubecost module for Product Catalog application!

This module is not used in subsequent steps, so you can remove the resources now, or at the end of the workshop:

## Delete Kubecost:

Uninstall the ingress resource and Kubecost

```bash
kubectl delete ingress -n kubecost
helm uninstall kubecost kubecost/cost-analyzer --namespace kubecost
```

## Delete the AWS Load Balancer Controller

Uninstall the AWS Load Balancer Controller.

```bash
helm uninstall aws-load-balancer-controller -n kube-system
```

Delete the service account created for AWS Load Balancer Controller.

```bash
eksctl delete iamserviceaccount    --cluster $CLUSTER_NAME   --name aws-load-balancer-controller   --namespace kube-system   --wait
```

Delete the IAM Policy created for the AWS Load Balancer Controller.

```bash
aws iam delete-policy   --policy-arn arn:aws:iam::${AWS_ACCOUNT_ID}:policy/AWSLoadBalancerControllerIAMPolicy
````

You should also delete the cloned repository product-catalog within your GitHub account.
