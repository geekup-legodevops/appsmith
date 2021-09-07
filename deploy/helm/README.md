
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
## Parameters

### Global parameters

| Name 											 | Description 																								| Value 	|
| -------------------------- | ---------------------------------------------------------- | ------- |
| `global.namespaceOverride` | Override the namespace for resource deployed by the chart	| `""`	 	| 
| `global.storageClass`			 | Global StorageClass for Persistent Volume(s)								| `""`  	|

### Common parameters
| Name 								| Description 																			| Value 				|
| ------------------- | ------------------------------------------------- | ------------- |
| `fullnameOverride`  | String to fully override appsmith.name	template	| `""`	 				| 
| `containerName`			| Specify container's name running in the pods			| `"appsmith"` 	|
| `commonLabels`      | Labels to add to all deployed objects							| `{}` 					|
| `commonAnnotations`	| Annotations to add to all deployed objects 				| `{}` 					|

### Appsmith Image parameters
| Name 								| Description 								| Value 											|
| -------------------	| --------------------------- | --------------------------- |
| `image.registry`		| Appsmith image registry			| `registry-gitlab.geekup.io` |
| `image.repository`	| Appsmith image repository		| `gu_lego_3/appsmith_v2` 		|
| `image.tag`					| Appsmith image tag					| `latest` 										|
| `image.pullPolicy`	| Appsmith image pull policy	| `Always` 										|

### Appsmith deployment parameters
| Name 											 	| Description 																				| Value 					|
| --------------------------- | --------------------------------------------------- | --------------- |
| `strategyType`							| Appsmith deployment strategy type										| `RollingUpdate` |
| `schedulerName`							| Alternate scheduler																	| `""`						|
| `podAnnotations`						| Annotations for Appsmith pods												| `{}`						|
| `podSecurityContext`				| Appsmith pods security context											| `{}`						|
| `securityContext`						| Set security context																| `{}`						|
| `resources.limit`						| The resources limits for the Appsmith container			| `{}`						|
| `resources.requests`				| The requested resources for the Appsmith container	| `{}`						|
| `nodeSelector`							| Node labels for pod assignment											| `{}`						|
| `tolerations`								| Tolerations for pod assignment											| `[]`						|
| `affinity`									| Affinity fod pod assignment													| `{}`						|

### Appsmith service account parameters
| Name 											 		| Description 																																				 												| Value 	|
| ----------------------------- | ----------------------------------------------------------------------------------------------------------- | ------- |
| `serviceAccount.create`    		| Enable creation of `ServiceAccount` for Appsmith pods															 													| `true` 	|
| `serviceAccount.name`      		| Name of the created `ServiceAccount` . If not set, a name is generated using the appsmith.fullname template	| `""` 		|
| `serviceAccount.annotations` 	| Additional service account annotations																						 													| `{}` 		|

### Traffic Exposure Parameters
| Name 											 					| Description 																																				 		| Value 			|
| ----------------------------------- | --------------------------------------------------------------------------------------- | ----------- |
| `service.type` 						 					| Appsmith service type																															 			| `ClusterIP` |
| `service.port`						 					| Appsmith service port																															 			| `80` 				|
| `service.portName` 				 					| Appsmith service port name																													 		| `appsmith` 	|
| `service.clusterIP`        					| Appsmith service Cluster																														 		| `""` 				|
| `service.loadBalancerIP`   					| Appsmith service Load Balancer IP																									 			| `""` 				|
| `service.loadBalancerSourceRanges`	| Appsmith service Load Balancer sources                                      						| `[]` 				|
| `service.annotations` 		 					| Additional custom annotations for Appsmith service 																 			| `{}` 				|
| `ingress.enabled` 				 					| Enable ingress record generation for Appsmith                                       		| `false` 		|
| `ingress.hosts`            					| An array of hosts to be covered with the ingress record                             		| `[]` 				|
| `ingress.tls`              					| Enable TLS configuration for the hosts defined at `ingress.hosts` parameter         		| `false` 		|
| `ingress.certManager`								| Add the corresponding annotations for cert-manager integration													| `false` 		|
| `ingress.secrets`										| Custom TLS certificates as secrets																											| `[]`				|

### Persistence parameters
| Name 											 					| Description 																													| Value 							|
| ----------------------------------- | --------------------------------------------------------------------- | ------------------- |
| `persistence.enabled`								| Enable persistence using Persistent Volume Claims											| `true`							|
| `persistence.storageClass`					| Persistent Volume storage class																				| `""`								|
| `persistence.localStorage`					| Enable persistent volume using local storage													| `false`							|
| `persistence.storagePath`						| Local storage path																										| `/tmp/hostpath_pv`	|
| `persistence.localCluster`					| Local running cluster to provide storage space												| `[minikube]` 				|
| `persistence.accessModes`						| Persistent Volume access modes																				| `[ReadWriteOnce]`		|
| `persistence.size`									| Persistent Volume size																								|	`10Gi`							|
| `storageClass.enabled`							| Enable Storage Class configuration																		| `false`							|
| `storageClass.defaultClass`					| Create default Storage Class																					| `false`							|
| `storageClass.bindingMode`					| Binding mode for Persistent Volume Claims using Storage Class					| `Immediate`					|
| `storageClass.allowVolumeExpansion` | Allow expansion of Persistent Volume Claims using Storage Class				| `true`							|
| `storageClass.reclaimPolicy`				| Configure the retention of the dynamically created Persistent Volume	| `Delete`						|
| `storageClass.provisioner`					| Storage Class provisioner																							| `""`								|
| `storageClass.annotations`					| Additional storage class annotations																	| `{}`								|
| `storageClass.mountOptions`					| Mount options used by Persistent Volumes															| `{}`								|
| `storageClass.parameters`						| Storage Class parameters																							| `{}`								|

Specify each parameter using `--set key=value[,key=value]` argument to helm install. For example:
```
helm install appsmith \
--set ingress.enabled=true,persistence.storageClass=appsmith-pv \
	deploy/helm
```
The above command enable the ingress service and specify the storage class name