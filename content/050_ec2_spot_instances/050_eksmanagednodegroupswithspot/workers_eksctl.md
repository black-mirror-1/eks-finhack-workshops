---
title: "Create EKS managed node groups with Spot capacity"
date: 2018-08-07T11:05:19-07:00
weight: 54
draft: false
---

In this section we will deploy the instance types we selected in previous chapter and create managed node groups that adhere to Spot diversification best practices. We will use **[`eksctl create nodegroup`](https://eksctl.io/usage/managing-nodegroups/)** to achieve this.

Let's first create the configuration file:

```
cat << EOF > add-mng-spot.yml
---
apiVersion: eksctl.io/v1alpha5
kind: ClusterConfig

managedNodeGroups:
- name: mng-spot-4vcpu-8gb
  desiredCapacity: 2
  minSize: 0
  maxSize: 4
  spot: true
  instanceTypes:
  - c5.xlarge
  - c5a.xlarge
  - c5ad.xlarge
  - c5d.xlarge
  - c6a.xlarge
  taints:
    - key: spotInstance
      value: "true"
      effect: NoSchedule
  labels:
    intent: apps

metadata:
  name: ${EKSCLUSTER_NAME}
  region: ${AWS_REGION}
  version: "1.22"

EOF
```
Create new EKS managed node groups with Spot Instances. 

```
eksctl create nodegroup --config-file=add-mng-spot.yml
```
{{% notice info %}}
Creation of node groups will take 3-4 minutes. 
{{% /notice %}}

There are a few things to note in the configuration that we just used to create these node groups.

 * Node groups configurations are set under the **managedNodeGroups** section, this indicates that the node groups are managed by EKS.
 * node group has **xlarge** (4 vCPU and 8 GB) instance types with **minSize** 0, **maxSize** 4 and **desiredCapacity** 2.
 * The configuration **spot: true** indicates that the node group being created is a EKS managed node group with Spot capacity.
 * We applied a **[Taint](https://kubernetes.io/docs/concepts/configuration/taint-and-toleration/)** `spotInstance: "true:PreferNoSchedule"`. **PreferNoSchedule** is used to indicate we prefer pods not be scheduled on Spot Instances. This is a “preference” or “soft” version of **NoSchedule** – the system will try to avoid placing a pod that does not tolerate the taint on the node, but it is not required.
 * **intent**, to allow you to deploy stateless applications on nodes that have been labeled with value **apps**

{{% notice note %}}
Since eksctl 0.41, integrates with the instance selector ! This can create more convenient configurations that apply diversification of instances in a concise way.
As an exercise, [read eks instance selector documentation](https://eksctl.io/usage/instance-selector/) and figure out which changes you may need to apply the configuration changes using instance selector.
At the time of writing this workshop, we have not included this functionality as there is a pending feature we'd need to deny a few instances [Read more about this here](https://github.com/weaveworks/eksctl/issues/3718)
{{% /notice %}}


{{% notice info %}}
If you are wondering at this stage: *Where is spot bidding price ?* you are missing some of the changes EC2 Spot Instances had since 2017. Since November 2017 [EC2 Spot price changes infrequently](https://aws.amazon.com/blogs/compute/new-amazon-ec2-spot-pricing/) based on long term supply and demand of spare capacity in each pool independently. You can still set up a **maxPrice** in scenarios where you want to set maximum budget. By default *maxPrice* is set to the On-Demand price; Regardless of what the *maxPrice* value, Spot Instances will still be charged at the current Spot market price.
{{% /notice %}}

### Confirm the Nodes

{{% notice tip %}}
Aside from familiarizing yourself with the kubectl commands below to obtain the cluster information, you should also explore your cluster using **kube-ops-view** and find out the nodes that were just created.
{{% /notice %}}

Confirm that the new nodes joined the cluster correctly. You should see the nodes added to the cluster.

```
kubectl get nodes
```

Managed node groups automatically create a label **eks.amazonaws.com/capacityType** to identify which nodes are Spot Instances and which are On-Demand Instances so that we can schedule the appropriate workloads to run on Spot Instances. You can use this node label to identify the lifecycle of the nodes

```
kubectl get nodes \
  --label-columns=eks.amazonaws.com/capacityType \
  --selector=eks.amazonaws.com/capacityType=SPOT
```
The output of this command should return nodes running on Spot Instances. The output of the command shows the **CAPACITYTYPE** for the current nodes is set to **SPOT**.

```
NAME                                        STATUS   ROLES    AGE     VERSION                CAPACITYTYPE
ip-10-4-28-74.us-west-2.compute.internal    Ready    <none>   2m27s   v1.22.12-eks-ba74326   SPOT
ip-10-4-35-132.us-west-2.compute.internal   Ready    <none>   2m26s   v1.22.12-eks-ba74326   SPOT
```

Now we will show all nodes running on On Demand Instances. The output of the command shows the **CAPACITYTYPE** for the current nodes is set to **ON_DEMAND**.

```
kubectl get nodes \
  --label-columns=eks.amazonaws.com/capacityType \
  --selector=eks.amazonaws.com/capacityType=ON_DEMAND
```
```
NAME                                        STATUS   ROLES    AGE   VERSION                CAPACITYTYPE
ip-10-4-2-10.us-west-2.compute.internal     Ready    <none>   52m   v1.22.12-eks-ba74326   ON_DEMAND
ip-10-4-61-151.us-west-2.compute.internal   Ready    <none>   52m   v1.22.12-eks-ba74326   ON_DEMAND
ip-10-4-77-113.us-west-2.compute.internal   Ready    <none>   52m   v1.22.12-eks-ba74326   ON_DEMAND
ip-10-4-91-227.us-west-2.compute.internal   Ready    <none>   52m   v1.22.12-eks-ba74326   ON_DEMAND
```
