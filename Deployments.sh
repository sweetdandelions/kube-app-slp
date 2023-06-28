kubectl create namespace snaplogic
kubectl apply -f snaplogic_secret.yaml -n snaplogic
helm upgrade --install snaplogic -n snaplogic helm_chart_v3