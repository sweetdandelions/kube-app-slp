# Install the Secrets Store CSI Driver 
helm repo add secrets-store-csi-driver https://kubernetes-sigs.github.io/secrets-store-csi-driver/charts
helm install csi-secrets-store secrets-store-csi-driver/secrets-store-csi-driver --namespace kube-system --set syncSecret.enabled=true


# ASCP (AWS Secrets and Configuration Provider)
kubectl apply -f https://raw.githubusercontent.com/aws/secrets-store-csi-driver-provider-aws/main/deployment/aws-provider-installer.yaml
#helm repo add aws-secrets-manager https://aws.github.io/secrets-store-csi-driver-provider-aws
#helm install -n kube-system secrets-provider-aws aws-secrets-manager/secrets-store-csi-driver-provider-aws


# Install SnapLogic application
kubectl create namespace snaplogic
helm upgrade --install snaplogic -n snaplogic ../helm_chart_v3
#kubectl apply -f ../secrets/snaplogic_secret.yaml -n snaplogic


# Deploy Metrics server for CA/Karpenter
helm repo add metrics-server https://kubernetes-sigs.github.io/metrics-server/
helm upgrade --install metrics-server metrics-server/metrics-server


# Deploy Cluster Autoscaler
kubectl apply -f ../yaml/caDeployment.yaml


# Install Prometheus & KEDA
#helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
#helm repo add kedacore https://kedacore.github.io/charts
#helm repo update

#helm install prometheus prometheus-community/prometheus --namespace monitoring --create-namespace
#helm install keda kedacore/keda --namespace keda --create-namespace

