kubctl create namespace kube-gateway

# On first install only
kubectl create secret generic -n kube-gateway memberlist --from-literal=secretkey="$(openssl rand -base64 128)" --create-namespace

# add app on ArgoCD
