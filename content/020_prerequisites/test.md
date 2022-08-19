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

## Access kube-ops-view

```
echo "Kube-ops-view URL: http://$(kubectl get ingress kube-ops-view-ingress -o  jsonpath="{.status.loadBalancer.ingress[0].hostname}")"
```

This will display a line similar to `Kube-ops-view URL = http://<URL_PREFIX_ELB>.amazonaws.com`
Opening the URL in your browser will provide the current state of our cluster.

{{% notice note %}}
You may need to refresh the page and clean your browser cache. The creation and setup of the LoadBalancer may take a few minutes; usually in two minutes you should see kub-ops-view. 
{{% /notice %}}

![kube-ops-view](/images/using_ec2_spot_instances_with_eks/helm/kube-ops-view.png)

As this workshop moves along and you create Spot workers, and perform scale up and down actions, you can check the effects and changes in the cluster using kube-ops-view. Check out the different components and see how they map to the concepts that we have already covered during this workshop.

{{% notice tip %}}
Spend some time checking the state and properties of your EKS cluster. 
{{% /notice %}}

![kube-ops-view](/images/using_ec2_spot_instances_with_eks/helm/kube-ops-view-legend.png)

#### Congratulations!

You now have a fully working Amazon EKS Cluster that is ready to use!
