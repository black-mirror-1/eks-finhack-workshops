---
title: "Deploy Application"
date: 2018-08-07T08:30:11-07:00
weight: 37
---

To deploy the application we just need to run:
```
kubectl apply -f ~/environment/monte-carlo-pi-service.yml 
```
This should prompt:
```
service/monte-carlo-pi-service created
deployment.apps/monte-carlo-pi-service created
```


### Testing the application

Once the application has been deployed we can use the following line to find out the external url to access the Monte Carlo Pi approximation service. To get the url of the service: 
```
kubectl get svc monte-carlo-pi-service | tail -n 1 | awk '{ print "monte-carlo-pi-service URL = http://"$4 }'
```

{{% notice note %}}
You may need to refresh the page and clean your browser cache. The creation and setup of the LoadBalancer may take a few minutes; usually in two minutes you should see the response of the
monte-carlo-pi-service.
{{% /notice %}}

When running that in your browser you should be able to see the json response provided by the service:

![Monte Carlo Pi Approximation Response](/images/using_ec2_spot_instances_with_eks/deploy/monte_carlo_pi_output_1.png)

{{% notice note %}}
The application takes the named argument **iterations** to define the number of samples used during the
monte carlo process, this can be useful to increase the CPU demand on each request. 
{{% /notice %}}

You can also execute a request with the additional parameter from the console:
```
URL=$(kubectl get svc monte-carlo-pi-service | tail -n 1 | awk '{ print $4 }')
time curl ${URL}/?iterations=100000000
```