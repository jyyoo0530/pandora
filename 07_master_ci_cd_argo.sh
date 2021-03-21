## Argo
#prepare
kubectl create namespace clt-devops
ARGO=./cicd/argo
mkdir -p $ARGO
#install argo in k8s
curl -o $ARGO/argo-install.yaml https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
sed -i 's/namespace: argocd/namespace: clt-devops/g' $ARGO/argo-install.yaml
cat <<EOF > ./externalservice.yaml
---
apiVersion: v1
kind: Service
metadata:
  name: argocd-server-external
  labels:
    app.kubernetes.io/component: server
    app.kubernetes.io/name: argocd-server
    app.kubernetes.io/part-of: argocd
spec:
  type: NodePort
  ports:
    - port: 443
      targetPort: 8080
      protocol: TCP
      name: http
      nodePort: 30002
  selector:
    app.kubernetes.io/name: argocd-server
---
EOF
cat externalservice.yaml>>$ARGO/argo-install.yaml
rm -f externalservice.yaml

kubectl apply -f $ARGO/argo-install.yaml -n clt-devops
# install argocd cli
VERSION=$(curl --silent "https://api.github.com/repos/argoproj/argo-cd/releases/latest" | grep '"tag_name"' | sed -E 's/.*"([^"]+)".*/\1/')
curl -sSL -o /usr/local/bin/argocd https://github.com/argoproj/argo-cd/releases/download/$VERSION/argocd-linux-amd64
chmod +x /usr/local/bin/argocd
# patch
kubectl patch svc argocd-server -n clt-devops -p '{"spec": {"type": "NodePort"}}'
# get password
kubectl get pods -n clt-devops -l app.kubernetes.io/name=argocd-server -o name | cut -d'/' -f 2