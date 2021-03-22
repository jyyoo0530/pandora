kubectl edit configmap -n kube-system kube-proxy

kubectl get configmap kube-proxy -n kube-system -o yaml | \
sed -e "s/strictARP: false/strictARP: true/" | \
kubectl diff -f - -n kube-system

kubectl get configmap kube-proxy -n kube-system -o yaml | \
sed -e "s/strictARP: false/strictARP: true/" | \
kubectl apply -f - -n kube-system

# On first install only
kubectl create secret generic -n clt-devops memberlist --from-literal=secretkey="$(openssl rand -base64 128)"

# add app on ArgoCD