Clone the repo

```
git clone git@github.com:sweetdandelions/kube-app-slp.git
cd kube-app-slp/
```
You need to have an AWS account set up
Terraform, kubectl and Helm installed

```
terraform init
terraform plan
terraform apply --auto-approve
```
Execute the commands (from the Deployments.sh file)
```
kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml

kubectl create namespace monitoring
kubectl create namespace snaplogic

helm repo add prometheus-community https://prometheus-community.github.io/helm-charts

helm repo update

helm upgrade --install prometheus prometheus-community/kube-prometheus-stack -n monitoring -f custom_values.yaml

helm upgrade --install prometheus-adapter prometheus-community/prometheus-adapter --namespace monitoring -f adapter_custom_values.yaml

kubectl get --raw /apis/custom.metrics.k8s.io/v1beta1 | jq .
```
The resources are returned:

![Response](https://github.com/sweetdandelions/kube-app-slp/blob/main/Screenshot%202023-05-21%20221826.png)
