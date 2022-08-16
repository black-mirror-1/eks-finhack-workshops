---
title: "Cost visibility with Kubecost"
menuTitle: "Cost visibility with Kubecost"
weight: 40
pre: "<b>1. </b>"
---

[Kubecost](https://www.kubecost.com/) is a tool from Stackwatch which provides cost monitoring and capacity management solutions. Its available as a CNCF project, in the name of Opencost.

## Why Kubecost?

Kubecost is an open source solution for cost management, which provides real time cost visibility and savings insights for Kubernetes. Adoption of container orchestration like Kubernetes/EKS grew a lot, but the cost is one of the challenging part. Because of the ephemeral nature of containers, which might scale in and scale out depending on the needs, adds more complexity. Hence, cost and usage is crucial for this. Kubecost helps customers adopt Amazon EKS and ECS and showing the spend patterns and resource efficiency. Also, Kubecost is available in the AWS marketplace as well. When installing Kubecost, it installs Prometheus and Grafana under the hood. Kubecost queries the resource usage using the Kubernetes APIs and store the results into time series database like Prometheus, as shown in the block diagram below.

In this chapter, we will see how to install and configure Kubecost and see how to measure the cost allocation of various components at namespace level, deployment level and pod level. We will also see the resource efficiency to check whether the deployments are over provisioned or under provisioned, health of the system, etc.

## Pre-requisites

If workshop application is NOT installed yet, you have to complete Deploy Microservices

chapter before working on this chapter. This chapter works with the basic cluster setup and does not require larger nodegroup.

Verify if Git is installed

```bash
git --version
```

Configure Git CLI with your username.

```bash
git config --global user.name "YOUR_GIT_USER_NAME"
git config --global user.email "YOUR_GIT_EMAIL"
```

Generate Personal Access Token for Git API access.

https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/creating-a-personal-access-token#creating-a-token
Export the environment variables as below.

```bash
export CLUSTER_NAME=`eksctl get cluster|awk '{print $1}'|tail -1`
export REGION=`eksctl get cluster|awk '{print $2}'|tail -1`
export AWS_ACCOUNT_ID=`aws sts get-caller-identity|grep "Arn"|cut -d':' -f6`
```

Check if the values are set properly by checking below

```bash
echo $CLUSTER_NAME
echo $REGION
echo $AWS_ACCOUNT_ID
```

Typical output will be like below (Your ouput may vary)

```
echo $CLUSTER_NAME
eksworkshop-eksctl

echo $REGION
us-east-2

echo $AWS_ACCOUNT_ID 
123456789012
```