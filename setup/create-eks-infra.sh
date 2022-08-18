#!/bin/bash

# SPDX-FileCopyrightText: Copyright 2021 Amazon.com, Inc. or its affiliates.
# SPDX-License-Identifier: MIT-0

# If env variables exists use that value or set a default value

export EKSCLUSTER_NAME="${EKSCLUSTER_NAME:-eksworkshop-eksctl}"
export ACCOUNTID="${ACCOUNTID:-$(aws sts get-caller-identity --query Account --output text)}"
export AWS_REGION="${AWS_REGION:-$(curl -s 169.254.169.254/latest/dynamic/instance-identity/document | jq -r '.region')}"
export EKS_VERSION="${EKS_VERSION:-1.22}"
# get the link to the same version as EKS from here https://docs.aws.amazon.com/eks/latest/userguide/install-kubectl.html

cd ~/environment/eks-finhack-workshops

echo "==============================================="
echo "  Create EKS Cluster ......"
echo "==============================================="
sed -i -- 's/{AWS_REGION}/'$AWS_REGION'/g' setup/eks-cluster/eksctl-config.yml
sed -i -- 's/{EKSCLUSTER_NAME}/'$EKSCLUSTER_NAME'/g' setup/eks-cluster/eksctl-config.yml
sed -i -- 's/{EKS_VERSION}/'$EKS_VERSION'/g' setup/eks-cluster/eksctl-config.yml
sed -i -- 's/{ACCOUNTID}/'$ACCOUNTID'/g' setup/eks-cluster/eksctl-config.yml

eksctl create cluster -f setup/eks-cluster/eksctl-config.yml
aws eks update-kubeconfig --name $EKSCLUSTER_NAME --region $AWS_REGION

CONTROLPLANE_SG=$(aws eks describe-cluster --name $EKSCLUSTER_NAME --region $AWS_REGION --query cluster.resourcesVpcConfig.clusterSecurityGroupId --output text)
DNS_IP=$(kubectl get svc -n kube-system | grep kube-dns | awk '{print $3}')
CLUSTER_ENDPOINT=$(aws eks describe-cluster --region ${AWS_REGION} --name ${EKSCLUSTER_NAME} --query 'cluster.endpoint' --output text)
B64_CA=$(aws eks describe-cluster --region ${AWS_REGION} --name ${EKSCLUSTER_NAME} --query 'cluster.certificateAuthority.data' --output text)
VPC_ID=$(aws eks describe-cluster --name $EKSCLUSTER_NAME --region $AWS_REGION --query cluster.resourcesVpcConfig.vpcId --output text)


echo "==============================================="
echo "  Install Metrics Server ......"
echo "==============================================="

kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml

kubectl get apiservice v1beta1.metrics.k8s.io -o json | jq '.status'


echo "==============================================="
echo "  Deploy AWS Loadbalancer Controller ......"
echo "==============================================="

curl -o ~/environment/iam_policy.json https://raw.githubusercontent.com/kubernetes-sigs/aws-load-balancer-controller/v2.4.3/docs/install/iam_policy.json

aws iam create-policy --policy-name AWSLoadBalancerControllerIAMPolicy  --policy-document file://~/environment/iam_policy.json

eksctl create iamserviceaccount \
    --cluster=$EKSCLUSTER_NAME \
    --namespace=kube-system \
    --name=aws-load-balancer-controller \
    --attach-policy-arn=arn:aws:iam::$ACCOUNTID:policy/AWSLoadBalancerControllerIAMPolicy \
    --override-existing-serviceaccounts \
    --region $AWS_REGION --approve

helm repo add eks https://aws.github.io/eks-charts

helm install aws-load-balancer-controller eks/aws-load-balancer-controller \
    -n kube-system \
    --set clusterName=$EKSCLUSTER_NAME \
    --set serviceAccount.create=false \
    --set serviceAccount.name=aws-load-balancer-controller \
    --set nodeSelector.intent=control-apps

kubectl get pods -n kube-system

echo "==============================================="
echo "  Install kubeops view ......"
echo "==============================================="

helm repo add k8s-at-home https://k8s-at-home.com/charts/
helm repo update

helm install kube-ops-view k8s-at-home/kube-ops-view

cat <<EOF | kubectl apply -f -
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: kube-ops-view-ingress
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
            name: kube-ops-view 
            port:
               number: 8080
EOF

echo "Kube-ops-view URL: http://$(kubectl get ingress kube-ops-view-ingress -o  jsonpath="{.status.loadBalancer.ingress[0].hostname}")"



echo "==============================================="
echo "  Install Kubecost ......"
echo "==============================================="

kubectl create namespace kubecost 

helm repo add kubecost https://kubecost.github.io/cost-analyzer/ 
helm install kubecost kubecost/cost-analyzer \
    --namespace kubecost \
    --set kubecostToken="Zy5zaXZhQHlhaG9vLmNvbQ==xm343yadf98" 

kubectl get ingressclass

kubectl get service -n kubecost

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
  ingressClassName: alb 
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

echo "Kubecost URL: http://$(kubectl get ingress kubecost-ingress -n kubecost -o  jsonpath="{.status.loadBalancer.ingress[0].hostname}")"


