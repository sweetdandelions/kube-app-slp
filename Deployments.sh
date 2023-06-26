# kubectl get deployment metrics-server -n kube-system
kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml

kubectl create namespace monitoring
kubectl create namespace snaplogic

helm repo add prometheus-community https://prometheus-community.github.io/helm-charts

helm repo update

helm upgrade --install prometheus prometheus-community/kube-prometheus-stack --namespace monitoring -f custom_values.yaml

#kubectl apply -f components.yaml

# kubectl --namespace monitoring get pods -l "release=prometheus"
# kubectl get all -n monitoring

helm upgrade --install prometheus-adapter prometheus-community/prometheus-adapter --version "2.12.1" -n monitoring -f adapter_custom_values.yaml

# kubectl port-forward -n monitoring prometheus-prometheus-kube-prometheus-prometheus-0 8080:9090
# curl -X GET -kG "http:/localhost:9090/api/v1/query?" 

# kubectl get --raw /apis/custom.metrics.k8s.io/v1beta1
# kubectl get --raw /apis/custom.metrics.k8s.io/v1beta1 | jq .

helm upgrade --install snaplogic -n snaplogic helm_chart_v3

# kubectl get apiservice v1beta1.custom.metrics.k8s.io -o yaml
