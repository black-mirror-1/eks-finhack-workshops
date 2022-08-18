---
title: "Expose Kubecost"
date: 2021-11-07T11:05:19-07:00
weight: 43
draft: false
hidden: true
---

# Configure Ingress for Kubecost


## Create Ingress Class

Let us create the Ingress Class named aws-alb.

```bash
cat <<EOF | kubectl create -f -
apiVersion: networking.k8s.io/v1
kind: IngressClass 
metadata:
  name: aws-alb
spec:
  controller: ingress.k8s.aws/alb  
EOF
```

Output

```
ingressclass.networking.k8s.io/aws-alb created
```

Let’ s verify the IngressClass.

```bash
kubectl get ingressclass
```

Output
```
NAME      CONTROLLER            PARAMETERS                             AGE
alb       ingress.k8s.aws/alb   IngressClassParams.elbv2.k8s.aws/alb   3m7s
aws-alb   ingress.k8s.aws/alb   <none>                                 24s
```


## Create Ingress Resource

Lets create an Ingress resource which will define the forwarding rules for the traffic destined to the application. First lets check the services created for Kubecost.

```bash
kubectl get service -n kubecost
```

Output

```
NAME                                TYPE        CLUSTER-IP       EXTERNAL-IP   PORT(S)             AGE
kubecost-cost-analyzer              ClusterIP   10.100.184.113   <none>        9003/TCP,9090/TCP   22m
kubecost-grafana                    ClusterIP   10.100.246.203   <none>        80/TCP              22m
kubecost-kube-state-metrics         ClusterIP   10.100.232.43    <none>        8080/TCP            22m
kubecost-prometheus-node-exporter   ClusterIP   None             <none>        9100/TCP            22m
kubecost-prometheus-server          ClusterIP   10.100.136.111   <none>        80/TCP              22m
```

The first line shows the cost analyzer service, for which we need to create a forwarding rule. Let’ s use the below manifest and create the Ingress.


```bash
cat <<EOF | kubectl apply -f -
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  namespace: kubecost
  name: kubecost-ingress
  annotations:
    alb.ingress.kubernetes.io/scheme: internet-facing 
    alb.ingress.kubernetes.io/target-type: ip 
spec:
  ingressClassName: aws-alb 
  rules:
  - http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: kubecost-cost-analyzer 
            port:
               number: 9090
EOF
```

Output
```
ingress.networking.k8s.io/kubecost-ingress created
```

Let’s verify the Ingress in Kubernetes.

```bash
kubectl get ingress -n kubecost
```

Output
```
NAME               CLASS     HOSTS   ADDRESS                                                                  PORTS   AGE
kubecost-ingress   aws-alb   *       k8s-kubecost-kubecost-ec071365c4-110569893.us-east-1.elb.amazonaws.com 
```

AWS Load balancer controller helps provision an ALB and the ADDRESS is as mentioned above. Let’ s review the properties of the kubecost-ingress.

```bash
kubectl describe ingress kubecost-ingress -n kubecost
```

Output

```
Name:             kubecost-ingress
Namespace:        kubecost
Address:          k8s-kubecost-kubecost-ec071365c4-110569893.us-east-1.elb.amazonaws.com
Default backend:  default-http-backend:80 (<error: endpoints "default-http-backend" not found>)
Rules:
  Host        Path  Backends
  ----        ----  --------
  *           
              /   kubecost-cost-analyzer:9090 (192.168.8.155:9090)
Annotations:  alb.ingress.kubernetes.io/scheme: internet-facing
              alb.ingress.kubernetes.io/target-type: ip
Events:
  Type    Reason                  Age    From     Message
  ----    ------                  ----   ----     -------
  Normal  SuccessfullyReconciled  3m10s  ingress  Successfully reconciled
```

It will take a couple of minutes for the ALB to up and running. Make a note of the Address value above, which we will use it in the next step to access Kubecost dashboard.
