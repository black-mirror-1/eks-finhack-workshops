---
title: "Install AWS Load Balancer Controller"
date: 2021-11-07T11:05:19-07:00
weight: 42
draft: false
---

# Install AWS Load balancer controller

To access the Kubecost Dashboard, lets use the AWS load balancer controller.

## Get eks-cluster Information

Let’s check the EKS cluster name.

```bash
eksctl get cluster
```

Output

```
NAME                    REGION          EKSCTL CREATED
eksworkshop-eksctl      us-east-2       True
```

Note the cluster name eksworkshop-eksctl as we will use it in the next steps.

## Create IAM OIDC Provider

We need to associate our EKS cluster with IAM as an OIDC provider to use an IAM role for the service account that is used in AWS Load Balancer Controller. Sample command is shown below.

```bash
eksctl utils associate-iam-oidc-provider  --region $REGION --cluster $CLUSTER_NAME --approve
```

Output

```
2022-05-15 22:29:38 [ℹ]  eksctl version 0.93.0
2022-05-15 22:29:38 [ℹ]  using region us-west-2
2022-05-15 22:29:40 [ℹ]  will create IAM Open ID Connect provider for cluster "eksworkshop-cluster" in "us-west-2"
2022-05-15 22:29:42 [✔]  created IAM Open ID Connect provider for cluster "eksworkshop-cluster" in "us-west-2"
```

## Create IAM Policy for the AWS Load Balancer Controller

We need to create an IAM policy and associate it with the IAM role that the AWS Load Balancer Controller service account uses. First download the policy JSON file.

```bash
curl -o iam_policy.json https://raw.githubusercontent.com/kubernetes-sigs/aws-load-balancer-controller/v2.4.3/docs/install/iam_policy.json
```

Output
```
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current                                 Dload  Upload   Total   Spent    Left  Speed
100  7617  100  7617    0     0  35979      0 --:--:-- --:--:-- --:--:-- 35929
```

Create the IAM policy based on the JSON file you have just downloaded.

```bash
aws iam create-policy --policy-name AWSLoadBalancerControllerIAMPolicy  --policy-document file://iam_policy.json
```

Output
```
{    "Policy": {
        "PolicyName": "AWSLoadBalancerControllerIAMPolicy",
        "PolicyId": "ANPA2HDQZUN2Y2G7H7WG6",
        "Arn": "arn:aws:iam::123456789012:policy/AWSLoadBalancerControllerIAMPolicy",
        "Path": "/",
        "DefaultVersionId": "v1",
        "AttachmentCount": 0,
        "PermissionsBoundaryUsageCount": 0,
        "IsAttachable": true,
        "CreateDate": "2022-05-15T22:49:51+00:00",
        "UpdateDate": "2022-05-15T22:49:51+00:00"
    }
}
```

## Create an IAM Role and ServiceAccount for the AWS Load Balancer controllerHeader anchor link

In this step we will create an IAM role and associate the service account, that the AWS Load Balancer controller will use, with that IAM role. Sample command is shown below.

```bash
eksctl create iamserviceaccount --cluster=$CLUSTER_NAME --namespace=kube-system --name=aws-load-balancer-controller --attach-policy-arn=arn:aws:iam::$AWS_ACCOUNT_ID:policy/AWSLoadBalancerControllerIAMPolicy --override-existing-serviceaccounts --region $REGION --approve
```

In our case the cluster name is eksworkshop-eksctl,the account id is 123456789012 and the region is us-east-2.

Output

```
2022-05-15 22:52:05 [ℹ]  eksctl version 0.86.02022-05-15 22:52:05 [ℹ]  using region us-east-1
2022-05-15 22:52:05 [ℹ]  1 iamserviceaccount (kube-system/aws-load-balancer-controller) was included (based on the include/exclude rules)
2022-05-15 22:52:05 [!]  metadata of serviceaccounts that exist in Kubernetes will be updated, as --override-existing-serviceaccounts was set
2022-05-15 22:52:05 [ℹ]  1 task: { 
    2 sequential sub-tasks: { 
        create IAM role for serviceaccount "kube-system/aws-load-balancer-controller",
        create serviceaccount "kube-system/aws-load-balancer-controller",
    } }
2022-05-15 22:52:05 [ℹ]  building iamserviceaccount stack "eksctl-eksworkshop-eksctl-addon-iamserviceaccount-kube-system-aws-load-balancer-controller"
2022-05-15 22:52:05 [ℹ]  deploying stack "eksctl-eksworkshop-eksctl-addon-iamserviceaccount-kube-system-aws-load-balancer-controller"
2022-05-15 22:52:05 [ℹ]  waiting for CloudFormation stack "eksctl-eksworkshop-eksctl-addon-iamserviceaccount-kube-system-aws-load-balancer-controller"
2022-05-15 22:52:23 [ℹ]  waiting for CloudFormation stack "eksctl-eksworkshop-eksctl-addon-iamserviceaccount-kube-system-aws-load-balancer-controller"
2022-05-15 22:52:40 [ℹ]  waiting for CloudFormation stack "eksctl-eksworkshop-eksctl-addon-iamserviceaccount-kube-system-aws-load-balancer-controller"
2022-05-15 22:52:40 [ℹ]  created serviceaccount "kube-system/aws-load-balancer-controller"
```

## Deploy AWS Load Balancer Controller using Helm

Make sure have Helm installed by following the steps in the Using Helm section. If you have not then use the below command to install it.

```
curl -sSL https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3 | bash
```

Output

```
Downloading https://get.helm.sh/helm-v3.8.0-linux-amd64.tar.gzVerifying checksum... Done.
Preparing to install helm into /usr/local/bin
helm installed into /usr/local/bin/helm
```

Next, add the EKS chart Helm repo.

```bash
helm repo add eks https://aws.github.io/eks-charts
```
Output
```
"eks" has been added to your repositories
```

Next, deploy AWS Load Balancer Controller using the respective Helm chart. Sample command is shown below.

```bash
helm install aws-load-balancer-controller eks/aws-load-balancer-controller -n kube-system --set clusterName=$CLUSTER_NAME --set serviceAccount.create=false --set serviceAccount.name=aws-load-balancer-controller
```

In our case we used eksworkshop-eksctl as the cluster name.

Output

```
name=aws-load-balancer-controllerNAME: aws-load-balancer-controller
LAST DEPLOYED: Sun May 15 22:55:52 2022
NAMESPACE: kube-system
STATUS: deployed
REVISION: 1
TEST SUITE: None
NOTES:
AWS Load Balancer controller installed!
```

## Verify AWS Load Balancer Controller Deployment

Let’ s verify if the AWS Load Balancer Controllers are in healthy and running state.

```bash
kubectl get pods -n kube-system
```

Output
```
NAME                                            READY   STATUS    RESTARTS   AGE
aws-load-balancer-controller-6f978767cf-rlkpk   1/1     Running   0          15s
aws-load-balancer-controller-6f978767cf-xt6cs   1/1     Running   0          15s
aws-node-b7dn7                                  1/1     Running   0          29m
aws-node-l968g                                  1/1     Running   0          29m
coredns-7f5998f4c-84hqf                         1/1     Running   0          36m
coredns-7f5998f4c-d5grv                         1/1     Running   0          36m
kube-proxy-5ctm5                                1/1     Running   0          29m
kube-proxy-wjmbc                                1/1     Running   0          29m
```

The first two pods in the above output are the AWS Load Balancer Controller pods. This concludes this section. Let's explore configuring ingress for Kubecost next.


