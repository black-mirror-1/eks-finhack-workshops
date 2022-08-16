---
title: "Modify example Microservice to deploy on Spot"
chapter: true
weight: 60
---

# Modify example Microservice to deploy on Spot

There are two requirements that we should apply and implement in the configuration file:

 1. The first requirement is for the application to be deployed only on nodes that have been labeled with `intent: apps`
 2. The second requirement is for the application to prefer Spot Instances over on-demand instances.


In the next section we will explore how to implement this requirements.