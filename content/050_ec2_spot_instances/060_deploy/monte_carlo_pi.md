---
title: "Monte Carlo Pi Template"
date: 2018-08-07T08:30:11-07:00
weight: 61
---

## Monte Carlo Pi Template

Let's create a template configuration file for monte carlo pi application:

```
cat <<EoF > ~/environment/mcp-spot-svc.yml
---
apiVersion: v1 
kind: Service 
metadata: 
  name: mcp-spot-svc
  namespace: mcp-spot-svc 
spec: 
  type: ClusterIP 
  ports: 
    - port: 8080
      targetPort: 8080 
  selector: 
    app: mcp-spot-svc 
--- 
apiVersion: apps/v1 
kind: Deployment 
metadata: 
  name: mcp-spot-svc
  namespace: mcp-spot-svc 
  labels: 
    app: mcp-spot-svc 
spec: 
  replicas: 6 
  selector: 
    matchLabels: 
      app: mcp-spot-svc 
  template: 
    metadata: 
      labels: 
        app: mcp-spot-svc 
    spec:
      tolerations: 
      - key: "spotInstance" 
        operator: "Equal" 
        value: "true" 
        effect: "NoSchedule" 
      affinity: 
        nodeAffinity: 
          preferredDuringSchedulingIgnoredDuringExecution: 
          - weight: 1 
            preference: 
              matchExpressions: 
              - key: eks.amazonaws.com/capacityType 
                operator: In 
                values: 
                - SPOT 
          requiredDuringSchedulingIgnoredDuringExecution: 
            nodeSelectorTerms: 
            - matchExpressions: 
              - key: intent 
                operator: In 
                values: 
                - apps
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
  name: mcp-spot-svc-ingress
  namespace: mcp-spot-svc
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
            name: mcp-spot-svc 
            port:
               number: 8080
EoF

```

There are a few things to note in the configuration.

* This should create a `monte-carlo-pi-service.yml` template file that defines a **Service** and a **Deployment**. 
* The configuration instructs the cluster to deploy 6 replicas of a pod with a single container, that sets up [Resource request and limits](https://kubernetes.io/docs/concepts/configuration/manage-compute-resources-container/#resource-requests-and-limits-of-pod-and-container) to a fixed value 1vCPU and 2048Mi of RAM. You can read more about the differences between Resource requests and limits [here](https://docs.aws.amazon.com/eks/latest/userguide/platform-versions.html).
* During the Cluster creation the ON_DEMAND nodegroup, we added a taint `spotInstance: "true:NoSchedule"`. To overcome this taint, we need to added a toleration in the deployment. Read about how [tolerations](https://kubernetes.io/docs/concepts/configuration/taint-and-toleration/) are applied


{{% notice note %}}
There are a few best practices for managing multi-tenant dynamic clusters. One of those best practices is adding [Admission Controllers](https://kubernetes.io/docs/reference/access-authn-authz/admission-controllers/) such as the [ResourceQuota](https://kubernetes.io/docs/reference/access-authn-authz/admission-controllers/#resourcequota) and [LimitRanger](https://kubernetes.io/docs/reference/access-authn-authz/admission-controllers/#limitranger) admission controllers, both [supported by EKS](https://docs.aws.amazon.com/eks/latest/userguide/platform-versions.html)
{{% /notice %}}

