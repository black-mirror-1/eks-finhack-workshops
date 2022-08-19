---
title: "Stress-test the sytem"
date: 2018-08-07T08:30:11-07:00
weight: 94
---

We are now ready to test dynamic scaling using Horizontal Pod Autoscale and Karpenter.

### Deploying the Stress CLI to Cloud 9

To help us stress the application we will install a python helper app. The python helper application just calls in parallel on multiple process request to the monte-carlo-pi-service. This will generate load in our pods, which will also trigger the Horizontal Pod Autoscaler action for scaling the monte-carlo-pi-service replicaset.

```
chmod +x ~/environment/eks-finhack-workshops/workshops/karpenter/submit_mc_pi_k8s_requests.py
sudo python3 -m pip install -r ~/environment/eks-finhack-workshops/workshops/karpenter/requirements.txt
URL=$(kubectl get ingress mcp-spot-karpenter-ingress -n mcp-spot-karpenter | tail -n 1 | awk '{ print $4 }')
~/environment/eks-finhack-workshops/workshops/karpenter/submit_mc_pi_k8s_requests.py -p 1 -r 1 -i 1 -u "http://${URL}"
```

The output of this command should show something like:
```
Total processes: 1
Len of queue_of_urls: 1
content of queue_of_urls: ab79391edde2d11e9874706fbc6bc60f-1090433505.eu-west-1.elb.amazonaws.com/?iterations=1
100%|█████████████████████████████████████████████████████████████████████████████████████████████████████████| 1/1 [00:00<00:00, 8905.10it/s]
```

### Scaling our Application and Cluster

{{% notice note %}}
Before starting the stress test, predict what would be the expected outcome. Use **kube-ops-view** to verify that the changes you were expecting to happen, do in fact happen over time. 
{{% /notice %}}
{{%expand "Show me how to get kube-ops-view url" %}}
Execute the following command on Cloud9 terminal
```
kubectl get ingress kube-ops-view-ingress | tail -n 1 | awk '{ print "Kube-ops-view URL = http://"$4 }'
```
{{% /expand %}}

Run the stress test ! This time around we will run 3000 requests each expected to take ~1.3sec or so.
```
time ~/environment/eks-finhack-workshops/workshops/karpenter/submit_mc_pi_k8s_requests.py -p 100 -r 30 -i 35000000 -u "http://${URL}"
```

### Challenge 

While the application is running, can you answer the following questions ?

{{% notice tip %}}
Feel free to use [kubectl cheat sheet](https://kubernetes.io/docs/reference/kubectl/cheatsheet/) to find out your responses. You can open multiple tabs on Cloud9.
{{% /notice %}}








#### 1) How can we track the status of the Horizontal Pod Autoscheduler rule that was set up in the previous section ?  

{{%expand "Click here to show the answer" %}} 
 To display the progress of the rule was setup in Horizontal Pod Autoscaler we can run:
```
kubectl get hpa -n mcp-spot-karpenter -w
```
This should show the current progress and target pods, and refresh a new line every few seconds.
```
:~/environment $ kubectl get hpa -n mcp-spot-karpenter -w
NAME                     REFERENCE                           TARGETS   MINPODS   MAXPODS   REPLICAS   AGE
mcp-spot-karpenter  Deployment/mcp-spot-karpenter   0%/50%      4         100       4        33m
mcp-spot-karpenter   Deployment/mcp-spot-karpenter   0%/50%      4         100       4        34m
mcp-spot-karpenter   Deployment/mcp-spot-karpenter   100%/50%    4         100       4        35m
mcp-spot-karpenter   Deployment/mcp-spot-karpenter   100%/50%    4         100       8        35m
mcp-spot-karpenter   Deployment/mcp-spot-karpenter   94%/50%     4         100       8        36m
mcp-spot-karpenter   Deployment/mcp-spot-karpenter   94%/50%     4         100      16        36m
mcp-spot-karpenter   Deployment/mcp-spot-karpenter   92%/50%     4         100      16        37m
mcp-spot-karpenter   Deployment/mcp-spot-karpenter   92%/50%     4         100      19        37m
mcp-spot-karpenter   Deployment/mcp-spot-karpenter   94%/50%     4         100      19        38m
mcp-spot-karpenter   Deployment/mcp-spot-karpenter   85%/50%     4         100      19        39m
mcp-spot-karpenter   Deployment/mcp-spot-karpenter   85%/50%     4         100      19        39m
mcp-spot-karpenter   Deployment/mcp-spot-karpenter   54%/50%     4         100      19        40m
mcp-spot-karpenter   Deployment/mcp-spot-karpenter   0%/50%      4         100      19        41m
mcp-spot-karpenter   Deployment/mcp-spot-karpenter   0%/50%      4         100      19        45m
mcp-spot-karpenter   Deployment/mcp-spot-karpenter   0%/50%      4         100      12        46m
mcp-spot-karpenter   Deployment/mcp-spot-karpenter   0%/50%      4         100      12        47m
mcp-spot-karpenter   Deployment/mcp-spot-karpenter   0%/50%      4         100       4        48m
```

{{% /expand %}}

#### 2) How about the nodes or pods  ? 

{{%expand "Click here to show the answer" %}}
To display the node or pod you can use
```
kubectl top nodes
```

or 
```
kubectl top pods
```
{{% /expand %}}
