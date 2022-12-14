---
title: "Deploy the Microservice"
date: 2018-08-07T08:30:11-07:00
weight: 92
---

## Monte Carlo Pi Microservice

We are now ready to deploy our application. This time around we will deploy both a Service and a Deployment to serve our Monte Carlo microservice. We will apply all the techniques that we've seen in the previous Karpenter section. 

Let's create a template configuration file for monte carlo pi application:

```
cd ~/environment
cat <<EoF > ~/environment/mcp-spot-karpenter.yml
---
apiVersion: v1 
kind: Service 
metadata: 
  name: mcp-spot-karpenter
  namespace: mcp-spot-karpenter 
spec: 
  type: ClusterIP 
  ports: 
    - port: 8080
      targetPort: 8080 
  selector: 
    app: mcp-spot-karpenter 
--- 
apiVersion: apps/v1 
kind: Deployment 
metadata: 
  name: mcp-spot-karpenter
  namespace: mcp-spot-karpenter 
  labels: 
    app: mcp-spot-karpenter 
spec: 
  replicas: 6 
  selector: 
    matchLabels: 
      app: mcp-spot-karpenter 
  template: 
    metadata: 
      labels: 
        app: mcp-spot-karpenter 
    spec:
      tolerations: 
      - key: "spotInstance" 
        operator: "Equal" 
        value: "true" 
        effect: "NoSchedule" 
      nodeSelector:
        intent: apps
        kubernetes.io/arch: amd64
        karpenter.sh/capacity-type: spot
      containers: 
        - name: monte-carlo-pi-service 
          image: ruecarlo/monte-carlo-pi-service
          resources: 
            requests: 
              memory: "2048Mi" 
              cpu: "1024m" 
            limits: 
              memory: "2048Mi" 
              cpu: "1024m" 
          securityContext: 
            privileged: false 
            readOnlyRootFilesystem: true 
            allowPrivilegeEscalation: false 
          ports: 
            - containerPort: 8080 
---
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: mcp-spot-karpenter-ingress
  namespace: mcp-spot-karpenter
  annotations:
    alb.ingress.kubernetes.io/scheme: internet-facing 
    alb.ingress.kubernetes.io/target-type: ip 
spec:
  ingressClassName: alb 
  rules:
  - http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: mcp-spot-karpenter
            port:
               number: 8080
EoF

kubectl create namespace mcp-spot-karpenter
kubectl apply -f mcp-spot-karpenter.yml
```

This should create a `mcp-spot-karpenter.yml` template file that defines a **Service** and a **Deployment**. The configuration instructs the cluster to deploy two replicas of a pod with a single container, that sets up [Resource request and limits](https://kubernetes.io/docs/concepts/configuration/manage-compute-resources-container/#resource-requests-and-limits-of-pod-and-container) to a fixed value ~0.5vCPUs and 1024Mi of RAM.

Let's understand what happens when applying this configuration.


## Challenge

{{% notice tip %}}
You can use **Kube-ops-view** or just plain **kubectl** cli to visualize the changes and answer the questions below. In the answers we will provide the CLI commands that will help you check the resposnes. Remember: to get the url of **kube-ops-view** you can run the following command `echo "Kube-ops-view URL: http://$(kubectl get ingress kube-ops-view-ingress -o  jsonpath="{.status.loadBalancer.ingress[0].hostname}")"`
{{% /notice %}}

Answer the following questions. You can expand each question to get a detailed answer and validate your understanding.

#### 1) How many replicas would be created and which type of nodes would they be assigned to ?  

{{%expand "Click here to show the answer" %}} 

By now we should be quite familiar with answering this question, right.

The number of replicas has been defined in the manifest and has been set to 2.

As for the type of nodes:

* There was no `nodeSelector` set for `karpenter.sh/provisioner-name`, which means we are expecting Karpenter to use the default Provisioner. To remind ourselves of what was the configuration of the `default` Provisioner we can run. 

```
kubectl describe provisioner default
```

* There a nodeSelector for the `kubernetes.io/arch` set to `amd64` well-known label. If you check the compilation steps fo the microservice we just created, we did only push the `amd64` version of it.  

* There are nodeSelector defined for `intet:apps` so that the application does not get deployed into the OnDemand Managed Node groups

* There is also a nodeSelector for `karpenter.sh/capacity-type: spot`. We are expecting all the instances to be of Spot type. This means that the **AWS Node-Termination-Handler** Daemonset will get deployed automatically to the new Spot nodes created

We can confirm the statements above by checking Karpenter logs using the following command. By now you should be very familiar with the log lines expected.

```
kubectl logs -f deployment/karpenter -c controller -n karpenter
```

Or by runnint the following command to verify the details of the Spot instance created.

```
kubectl describe node $(kubectl get node --selector=intent=apps,karpenter.sh/capacity-type=spot -o json | jq ".items[].metadata.name"| sed s/\"//g)
```

{{% /expand %}}

#### 2) How can you get access to the Service URL ? 

{{%expand "Click here to show the answer" %}}

So far we have not exposed any service outside the **kube-ops-view**. Similar to what we did with **kube-ops-view**. Once the application has been deployed we can use the following line to find out the external url to access the Monte Carlo Pi approximation service. To get the url of the service: 

```
kubectl get ingress mcp-spot-karpenter-ingress -n mcp-spot-karpenter | tail -n 1 | awk '{ print "mcp-spot-karpenter service URL = http://"$4 }'
```

{{% notice note %}}
You may need to refresh the page and clean your browser cache. The creation and setup of the LoadBalancer may take a few minutes; usually in two minutes you should see the response of the monte-carlo-pi-service.
{{% /notice %}}

When running that in your browser you should be able to see the json response provided by the service:

![Monte Carlo Pi Approximation Response](/images/karpenter/deploy/monte_carlo_pi_output_1.png)

{{% notice note %}}
The application takes the named argument **iterations** to define the number of samples used during the monte carlo process, this can be useful to increase the CPU demand on each request. 
{{% /notice %}}

You can also execute a request with the additional parameter from the console:
```
URL=$(kubectl get svc monte-carlo-pi-service | tail -n 1 | awk '{ print $4 }')
time curl ${URL}/?iterations=100000000
```

{{% /expand %}}

Once you completed the questions above you shoudl be ready to move to the next section where we will configure HPA and prepare ourselves for a dynamic scaling exercise.