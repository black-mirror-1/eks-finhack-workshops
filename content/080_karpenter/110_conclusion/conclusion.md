---
title: "What Have We Accomplished"
chapter: false
weight: 111
---

**Congratulations!** you have reached the end of the workshop. We covered a lot of ground on how to scale kubernetes clusters efficiently using Karpenter.

In the session, we have:

- Deployed and managed an EKS clusters with workers.
- Configured an EKS Cluster a few nodes using On-Demand Managed Node Groups to deploy control applications such as Karpenter
- Learned how Karpenter defines Provisioners and use those provisioners to provide a rich Service first approach to the way infrastructure gets provisioned that allows to apply specific labels and taints.
- We have learned how Karpenter support custom AMI's and bootsrapping.
- We learned how Karpenter uses well-known labels and acts on them procuring capacity that meets criterias such as which architecture to use, which type of instances (On-Demand or Spot) to use.
- We learned how Karpenter applies best practices for large scale deployment by diversifying and using allocation strategies for both on demand instances and EC2 Spot instances, we also learned applications have still full control and can set Node Selectors such as `node.kubernetes.io/instance-type: m5.2xlarge` or `topology.kubernetes.io/zone=us-east-1c` to specify explicitely what instance type to use or which AZ an application must be deployed in.
- Configured a DaemonSet using **AWS-Node-Termination-Handler** to handle spot interruptions gracefully. We also learned that in future version the integration with the termination controller will be proactive in handling Spot Terminations and Rebalance recommendations.
 
# EC2 Spot Savings 

There is one more thing that we've accomplished by using EC2 Spot instances in the workshop!

  * Log into the **[EC2 Spot Request](https://console.aws.amazon.com/ec2sp/v1/spot/home)** page in the Console.
  * Click on the **Savings Summary** button.

![EC2 Spot Savings](/images/spot_savings_summary.png)

{{% notice note %}}
We have achieved a significant cost saving over On-Demand prices that we can apply in a controlled way and at scale. We hope this helps you use Karpenter to simpify your deployments and use EC2 Spot Instances for your stateless, flexible workloads. We hope this savings will help you try new experiments or build other cool projects. **Now Go Build** !
{{% /notice %}}

{{< youtube 3wGeqmSwz9k >}}