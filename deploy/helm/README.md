
# Appsmith
Appsmith is a JS-based internal tool development platform. Internal tools take a lot of time to build even though they involve the same UI components, data integrations, and user access management. Developers love Appsmith because it saves them hundreds of hours.

Build interactive web apps by using UI components like a table, form components, button, charts, rich text editor, map, tabs, modal, and many more.

API Support: CURL importer for REST APIs Database Support: PostgreSQL, MongoDB, MySQL, Redshift, Elastic Search, DynamoDB, Redis, & MSFT SQL Server.
## TL;DR
---
```
helm repo add appsmith https://appsmithorg.github.io/appsmith

helm repo update

helm install appsmith deploy/helm
```

## Introduction
---
This chart bootstrap an [Appsmith](https://github.com/appsmithorg/appsmith) deployment on a [Kubernetes](kubernetes.io) cluster using [Helm](https://helm.sh) package manager.

## Prerequisites
---
* Install Helm package manager: [https://helm.sh/docs/intro/install/](https://helm.sh/docs/intro/install/)
* Ensure `kubectl` is installed and configured to connect to your cluster
    * Install kubeclt: [kubernetes.io/vi/docs/tasks/tools/install-kubectl/](https://kubernetes.io/vi/docs/tasks/tools/install-kubectl/)
    * Minikube: [Setup Kubectl](https://minikube.sigs.k8s.io/docs/handbook/kubectl/)
    * Google Cloud Kubernetes: [Configuring cluster access for kubectl
](https://cloud.google.com/kubernetes-engine/docs/how-to/cluster-access-for-kubectl)
    * Aws EKS: [Create a kubeconfig for Amazon EKS](https://docs.aws.amazon.com/eks/latest/userguide/create-kubeconfig.html)
    
    * Microk8s: [Working with kubectl](https://microk8s.io/docs/working-with-kubectl)
* Kubernetes NGINX Ingress Controller must be enable on your cluster by default. Please make sure that you install the right version for your cluster
    * Minikube: [Set up Ingress on Minikube with the NGINX Ingress Controller](https://kubernetes.io/docs/tasks/access-application-cluster/ingress-minikube/)
    * Google Cloud Kubernetes: [Ingress with NGINX controller on Google Kubernetes Engine](https://kubernetes.github.io/ingress-nginx/deploy/)
    * AWS EKS: [Install NGINX Controller for AWS EKS](https://kubernetes.github.io/ingress-nginx/deploy/#network-load-balancer-nlb)
    * Microk8s: [Add on: Ingress](https://microk8s.io/docs/addon-ingress)
* Script tested on Minikube with Kubernetes v1.18.0
* PV provisioner support in the underlying infrastructure
## Installing the Chart
---
To install the chart with the release `appsmith`
```
helm install appsmith deploy/helm
```
The command deploys Appsmith application on Kubernetes cluster in the default configuration. The [Parameters]() section lists the parameters that can be configured during installation.
## Uninstalling the Chart
---
To uninstall the `appsmith` release:
```
helm uninstall appsmith
```
The command uninstalls the release and removes all Kubernetes resources associated with the chart