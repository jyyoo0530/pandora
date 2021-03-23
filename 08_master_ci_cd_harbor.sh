HARBOR=./cicd/harbor
mkdir -p $HARBOR
#add helm chart
helm repo add harbor https://helm.goharbor.io

#make volume
ssh 30.0.2.31 -y #Node1 access
mkdir -p /data/harbor-registry
chmod 777 /data/harbor-registry
mkdir -p /data/harbor-cm
chmod 777 /data/harbor-cm
mkdir -p /data/harbor-js
chmod 777 /data/harbor-js
mkdir -p /data/harbor-db
chmod 777 /data/harbor-db
mkdir -p /data/harbor-redis
chmod 777 /data/harbor-redis
mkdir -p /data/harbor-trivy
chmod 777 /data/harbor-trivy
exit

# install cert-manager
wget -O $HARBOR/certmanager-crds.yaml https://github.com/jetstack/cert-manager/releases/download/v1.2.0/cert-manager.crds.yaml
kubectl apply -f $HARBOR/certmanager-crds.yaml -n kube-repo
kubectl label namespace kube-repo certmanager.k8s.io/disable-validation=true
helm repo add jetstack https://charts.jetstack.io
helm install cert-manager --namespace kube-repo jetstack/cert-manager

#export MY_DOMAIN=${MY_DOMAIN:-mylabs.dev}
#export LETSENCRYPT_ENVIRONMENT=${LETSENCRYPT_ENVIRONMENT:-staging}
#echo "${MY_DOMAIN} | ${LETSENCRYPT_ENVIRONMENT}"

kubectl create secret tls tls-cert --key /data/cert/30.0.2.30.key --cert /data/cert/30.0.2.30.crt -n kube-system

# install kubed
helm repo add appscode https://charts.appscode.com/stable/
helm install kubed appscode/kubed \
  --version v0.12.0 \
  --namespace kube-system \
  --set config.clusterName=pandora_cluster \
  --set apiserver.enabled=false
kubectl annotate secret ingress-cert-${LETSENCRYPT_ENVIRONMENT} -n clt-devops kubed.appscode.com/sync="app=kubed"

# run app
helm install harbor harbor/harbor -n kube-repo \
--set \
expose.type=ingress,\
expose.tls.enabled=true,\
expose.tls.certSource=secret,\
expose.tls.auto.commonName=harbor-operator,\
expose.tls.secret.secretName=default-server-secret,\
expose.tls.secret.notarySecretName=default-server-secret,\
expose.ingress.hosts.core=core.harbor.domain,\
expose.ingress.hosts.notary=notary.harbor.domain,\
expose.ingress.controller=default,\
expose.ingress.annotations=,\
harborAdminPassword=admin,\
persistence.enabled=true,\
persistence.resourcePolicy=keep,\
persistence.persistentVolumeClaim.registry.storageClass=harbor-registry-sc,\
persistence.persistentVolumeClaim.registry.accessMode=ReadWriteOnce,\
persistence.persistentVolumeClaim.registry.size=20Gi,\
persistence.persistentVolumeClaim.chartmuseum.storageClass=harbor-cm-sc,\
persistence.persistentVolumeClaim.chartmuseum.accessMode=ReadWriteOnce,\
persistence.persistentVolumeClaim.chartmuseum.size=20Gi,\
persistence.persistentVolumeClaim.jobservice.storageClass=harbor-js-sc,\
persistence.persistentVolumeClaim.jobservice.accessMode=ReadWriteOnce,\
persistence.persistentVolumeClaim.jobservice.size=5Gi,\
persistence.persistentVolumeClaim.database.storageClass=harbor-db-sc,\
persistence.persistentVolumeClaim.database.accessMode=ReadWriteOnce,\
persistence.persistentVolumeClaim.database.size=5Gi,\
persistence.persistentVolumeClaim.redis.storageClass=harbor-redis-sc,\
persistence.persistentVolumeClaim.redis.accessMode=ReadWriteOnce,\
persistence.persistentVolumeClaim.redis.size=5Gi,\
persistence.persistentVolumeClaim.trivy.storageClass=harbor-trivy-sc,\
persistence.persistentVolumeClaim.trivy.accessMode=ReadWriteOnce,\
persistence.persistentVolumeClaim.trivy.size=5Gi,\
metrics.enabled=true,\
metrics.core.path=/metrics,\
metrics.core.port=8001,\
metrics.registry.path=/metrics,\
metrics.registry.port=8001,\
metrics.exporter.path=/metrics,\
metrics.exporter.port=8001



kubectl delete crd chartmuseums.goharbor.io &&
kubectl delete crd cores.goharbor.io &&
kubectl delete crd harborclusters.goharbor.io &&
kubectl delete crd harbors.goharbor.io &&
kubectl delete crd jobservices.goharbor.io &&
kubectl delete crd notaryservers.goharbor.io &&
kubectl delete crd notarysigners.goharbor.io &&
kubectl delete crd portals.goharbor.io &&
kubectl delete crd registries.goharbor.io &&
kubectl delete crd registrycontrollers.goharbor.io &&
kubectl delete crd trivies.goharbor.io &&
kubectl delete crd tenants.minio.min.io