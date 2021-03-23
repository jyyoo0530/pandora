kubectl create namespace kube-security

# Generate a CA private key
openssl genrsa -out ca.key 2048

# Create a self signed Certificate, valid for 10yrs with the 'signing' option set
openssl req -x509 -new -nodes -key ca.key -subj "/C=KR/ST=Seoul/L=Seoul/O=example/OU=Personal/CN=30.0.2.30" -days 3650 -reqexts v3_req -extensions v3_ca -out ca.crt
kubectl create secret tls ca-key-pair \
   --cert=ca.crt \
   --key=ca.key \
   --namespace=kube-security

# apply crd by Argo
# run below
kubectl label namespace kube-security certmanager.k8s.io/disable-validation=true
# apply manager in Argo from Helm
helm repo add jetstack https://charts.jetstack.io
helm install cert-manager --namespace kube-repo jetstack/cert-manager