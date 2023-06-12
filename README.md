# kube-app-slp

git clone git@github.com:sweetdandelions/kube-app-slp.git

cd kube-app-slp/
terraform init
terraform apply --auto-approve


kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml

kubectl create namespace monitoring
kubectl create namespace snaplogic

helm repo add prometheus-community https://prometheus-community.github.io/helm-charts

helm repo update

helm upgrade --install prometheus prometheus-community/kube-prometheus-stack -n monitoring -f custom_values.yaml

helm upgrade --install prometheus-adapter prometheus-community/prometheus-adapter --namespace monitoring -f adapter_custom_values.yaml

kubectl get --raw /apis/custom.metrics.k8s.io/v1beta1 | jq .
