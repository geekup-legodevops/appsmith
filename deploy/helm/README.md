
**Note** No need to change directory to folder `helm`. Run command from project path

## 1. Install Helm chart dependencies 
```
helm dependency update ./deploy/helm
```

## 2. Install Helm chart
```
helm install appsmith ./deploy/helm
```

## 3. Port binding to access application
```
kubectl port-forward --namespace=appsmith service/appsmith  18081:80
```

## 4. Get kubernetes resource 
- Get resource with namespace (`--namespace=appsmith`)
E.g:
```
# Get pods
kubectl get pods --namespace=appsmith

# Get services
kubectl get services --namespace=appsmith

# Get persistent volume claim
kubectl get pvc --namespace=appsmith
```

**Note** In template `persistentVolume`, `minikube` cluster is used to setup persistent volume for local storage. Please change this value to your local cluster