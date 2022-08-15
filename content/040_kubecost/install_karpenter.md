---
title: "Install kubecost"
date: 2021-11-07T11:05:19-07:00
weight: 41
draft: false
---

All the components of the Kubecost can be installed using a manifest provided by the Kubecost Project. Note the outputs below that you should see.

```bash
kubectl create namespace kubecost 
```

Output

```
namespace/kubecost created
```

Install Kubecost using Helm -

```bash
helm repo add kubecost https://kubecost.github.io/cost-analyzer/ 
helm install kubecost kubecost/cost-analyzer --namespace kubecost --set kubecostToken="Zy5zaXZhQHlhaG9vLmNvbQ==xm343yadf98"
```

Output

```
W0515 22:21:00.059420   28065 warnings.go:70] policy/v1beta1 PodSecurityPolicy is deprecated in v1.21+, unavailable in v1.25+
W0515 22:21:01.286461   28065 warnings.go:70] policy/v1beta1 PodSecurityPolicy is deprecated in v1.21+, unavailable in v1.25+
W0515 22:21:45.953415   28065 warnings.go:70] policy/v1beta1 PodSecurityPolicy is deprecated in v1.21+, unavailable in v1.25+
W0515 22:21:45.956831   28065 warnings.go:70] policy/v1beta1 PodSecurityPolicy is deprecated in v1.21+, unavailable in v1.25+
NAME: kubecost
NAMESPACE: kubecost
STATUS: deployed
REVISION: 1
TEST SUITE: None
NOTES:
--------------------------------------------------
Kubecost has been successfully installed. When pods are Ready, you can enable port-forwarding with the following command:
    
    kubectl port-forward --namespace kubecost deployment/kubecost-cost-analyzer 9090
    
Next, navigate to http://localhost:9090 in a web browser.
Having installation issues? View our Troubleshooting Guide at http://docs.kubecost.com/troubleshoot-install
```
