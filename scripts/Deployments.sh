# Install application
kubectl create namespace snaplogic
kubectl apply -f ../secrets/snaplogic_secret.yaml -n snaplogic
helm upgrade --install snaplogic -n snaplogic ../helm_chart_v3

# Deploy Cluster Autoscaler
kubectl apply -f ../yaml/caDeployment.yaml

# Deploy metrics server
helm repo add metrics-server https://kubernetes-sigs.github.io/metrics-server/
helm upgrade --install metrics-server metrics-server/metrics-server

# Install Prometheus & KEDA
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo add kedacore https://kedacore.github.io/charts
helm repo update

helm install prometheus prometheus-community/prometheus --namespace monitoring --create-namespace
helm install keda kedacore/keda --namespace keda --create-namespace

