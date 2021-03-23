kubectl create namespace kube-security
# apply crd by Argo
# run below
kubectl label namespace kube-security certmanager.k8s.io/disable-validation=true
# apply manager in Argo from Helm
helm repo add jetstack https://charts.jetstack.io
helm install cert-manager --namespace kube-repo jetstack/cert-manager