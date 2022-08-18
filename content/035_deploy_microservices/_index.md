---
title: "Deploy an example Microservice"
chapter: true
weight: 35
pre: "<b>1. </b>"
---

# Deploy an example Microservice on On-Demand capacity

The microservice we will use as an example, is a trivial web service that uses a [Monte Carlo method to approximate pi](https://en.wikipedia.org/wiki/Monte_Carlo_integration) written in go. You can find the application code in in [this github repo](https://github.com/ruecarlo/eks-workshop-sample-api-service-go)

{{% notice note %}}
We will deploy the same sample microservice in different variations i.e., on Spot capacity and with autoscaling to compare the costs   
{{% /notice %}}

![Monte Carlo Pi Approximation](/images/using_ec2_spot_instances_with_eks/deploy/monte_carlo_pi.png)
