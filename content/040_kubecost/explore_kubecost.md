---
title: "Explore Kubecost"
date: 2021-11-07T11:05:19-07:00
weight: 44
draft: false
---

### Get the URL for Kubecost

As you could recollect from the previous step, lets take the URL address from below command:

```bash
kubectl get ingress -n kubecost
```

Output

```
NAME               CLASS     HOSTS   ADDRESS                                                                  PORTS   AGE
kubecost-ingress   aws-alb   *       k8s-kubecost-kubecost-ec071365c4-110569893.us-east-1.elb.amazonaws.com 
```

Copy the ADDRESS URL value that you see from your output. Open a browser and try this ADDRESS to reach the Kubecost dashboard.

![Initial Page](/images/kubecost/initial-dashboard.png)

clicking on the AWS cluster #1, it shows the overview page with various options as below:

![Overview](/images/kubecost/overview.png)

Click on Cost Allocation, which shows the namespace wise cost as below:



Click on “Aggregate by” and choose Deployment. Now, we could also see the cost by deployment wise as below:

![deploy-view](/images/kubecost/deploy-view.png)


Add Pod to the “Aggregate by” filter and thus we can further drill down to check the cost allocation at the level of pods as well, as below:

![pod-view](/images/kubecost/pod-view.png)

And we could check out the cost at service level as well: 

![svc-view](/images/kubecost/svc-view.png)

Click “Aggregate by” and choose “Namespace,Deployment”. From the results, click on the “workshop” namespace. This shows the namespace level cost allocation as below: 

![ns-view](/images/kubecost/ns-view.png)

Then under the “Controllers”, click on the deployments to see the information at the container level. For example, click on the deployment:productcatalog, which shows the container is under provisioned.

![reco-view](/images/kubecost/reco-view.png)

Click on the container name to see the summary as below: 

![summary-view](/images/kubecost/summary-view.png)

And from here, when clicking on the container link, it will open the Grafana dashboard as below: 

![grafana-view](/images/kubecost/grafana-view.png)

There are other features available with Kubecost as well, like Savings, Health, Reports and Alerts. Play around with various links. Couple of the sample snapshots below:

![snap1-view](/images/kubecost/snap1-view.png)

![snap2-view](/images/kubecost/snap2-view.png)