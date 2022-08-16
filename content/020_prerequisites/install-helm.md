---
title: "Install Helm"
chapter: false
weight: 23
---


## Introduction

Helm is the package manager for Kubernetes. Helm is the best way to find, share, and use software built for Kubernetes. Helm and Kubernetes work like a client/server application. The Helm client pushes resources to the Kubernetes cluster via kubernetes API.



![Helm](/images/prerequisites/helm1.png)
![Helm Architecture](/images/prerequisites/helm2.png)

Helm charts are Helm packages that consists of YAML template files organized into a specific directory structure. Charts are easy to create, version, share, and publish and are reusable by anyone for any environment, which reduces complexity and duplicates. Following is the file structure for a typical Helm chart:

```
example-chart/
├── Chart.yaml
├── templates
│   ├── deployment.yaml
│   ├── rbac.yaml
│   └── service.yaml
└── values.yaml
```

The [three basic concepts](https://helm.sh/docs/intro/using_helm/) of Helm charts are:

- Chart is a Helm package and contains all of the resource definitions necessary to run an application, tool, or service inside of a Kubernetes cluster.

- Release is an instance of a chart running in a Kubernetes cluster.

- Repository is the place where charts can be collected and shared for Kubernetes packages.

## Installation and Setup

Install Helm CLI

```bash
curl -sSL https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3 | bash
```

Verify the version

```bash
helm version --short
```

To list all charts

```bash
helm list
```

In the next section, we’ll demonstrate how Helm can be used to deploy our microservices.
