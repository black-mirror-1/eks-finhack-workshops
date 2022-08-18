---
title: "Quick Setup"
pre: "<b>   </b>"
weight: 12
tags:
  - beginner
---

# Infrastructure Setup

## Setup cloud9 IDE

Run the following scripts in [AWS CloudShell](https://us-west-2.console.aws.amazon.com/cloudshell?region=us-west-2). The default region is `us-west-2`. **Change it on your console if needed**.

```bash
# clone the repo
git clone https://github.com/black-mirror-1/eks-finhack-workshops.git
cd eks-finhack-workshops
````

Run this script to create Cloud9 IDE and assign an admin role to it
```bash
./setup/create-cloud9-ide.sh
```

Navigate to the Cloud9 IDE using the URL from the output of the script.

{{% notice warning %}}
NOTE: All the steps from now on are run within Clou9 IDE
{{% /notice %}}

## Validate the IAM role

Use the [GetCallerIdentity](https://docs.aws.amazon.com/cli/latest/reference/sts/get-caller-identity.html) CLI command to validate that the Cloud9 IDE is using the correct IAM role.

```bash
aws sts get-caller-identity --query Arn | grep eksworkshop-admin -q && echo "IAM role valid" || echo "IAM role NOT valid"
```

If the IAM role is not valid, <span style="color: red;">**DO NOT PROCEED**</span>. Manually attach the IAM role to the Cloud9 instance following the steps [here](/020_prerequisites/ec2instance.html).


## Install tools on cloud9 IDE

Setup the env variables required before installing the tools

```bash
# Install envsubst (from GNU gettext utilities) and bash-completion
sudo yum -y install jq gettext bash-completion moreutils

# Setup env variables required
export EKSCLUSTER_NAME=eksworkshop-eksctl
export ACCOUNTID=$(aws sts get-caller-identity --query Account --output text)
export AWS_REGION=$(curl -s 169.254.169.254/latest/dynamic/instance-identity/document | jq -r '.region')
export EKS_VERSION="1.22"
# get the link to the same version as EKS from here https://docs.aws.amazon.com/eks/latest/userguide/install-kubectl.html
export KUBECTL_URL="https://s3.us-west-2.amazonaws.com/amazon-eks/1.22.6/2022-03-09/bin/linux/amd64/kubectl"
```


Clone the git repository

```bash
cd ~/environment
git clone https://github.com/black-mirror-1/karpenter-for-emr-on-eks.git
cd ~/environment/karpenter-for-emr-on-eks
```

Install cloud9 cli tools

```bash
cd ~/environment/karpenter-for-emr-on-eks
./setup/c9-install-tools.sh
```

## Create EKS and Karpenter infrastructure

```bash
cd ~/environment/karpenter-for-emr-on-eks
./setup/create-eks-infra.sh
```
The script will do the following

* Create an EKS Cluster with 2 On-Demand [Managed nodegroups](https://docs.aws.amazon.com/eks/latest/userguide/managed-node-groups.html) (one for control apps and another for the workloads). eksclt-config.yaml
* Install and expose [Kube-ops-view](https://artifacthub.io/packages/helm/k8s-at-home/kube-ops-view) that can help visualize the resources in kubernetes cluster
* Deploy the [Metrics Server](https://github.com/kubernetes-sigs/metrics-server), a cluster-wide aggregator of resource usage data. We will nees that when we are setting the autoscaling.
* 


