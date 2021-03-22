HARBOR=./cicd/harbor
mkdir -p $HARBOR
#add helm chart
helm repo add harbor https://helm.goharbor.io

#create sc
cat <<EOF > $HARBOR/harbor-sc.yaml
---
kind: StorageClass
apiVersion: storage.k8s.io/v1
metadata:
  name: harbor-registry-sc
  namespace: clt-devops
provisioner: kubernetes.io/no-provisioner
volumeBindingMode: WaitForFirstConsumer
---
kind: StorageClass
apiVersion: storage.k8s.io/v1
metadata:
  name: harbor-cm-sc
  namespace: clt-devops
provisioner: kubernetes.io/no-provisioner
volumeBindingMode: WaitForFirstConsumer
---
kind: StorageClass
apiVersion: storage.k8s.io/v1
metadata:
  name: harbor-js-sc
  namespace: clt-devops
provisioner: kubernetes.io/no-provisioner
volumeBindingMode: WaitForFirstConsumer
---
kind: StorageClass
apiVersion: storage.k8s.io/v1
metadata:
  name: harbor-db-sc
  namespace: clt-devops
provisioner: kubernetes.io/no-provisioner
volumeBindingMode: WaitForFirstConsumer
---
kind: StorageClass
apiVersion: storage.k8s.io/v1
metadata:
  name: harbor-redis-sc
  namespace: clt-devops
provisioner: kubernetes.io/no-provisioner
volumeBindingMode: WaitForFirstConsumer
---
kind: StorageClass
apiVersion: storage.k8s.io/v1
metadata:
  name: harbor-trivy-sc
  namespace: clt-devops
provisioner: kubernetes.io/no-provisioner
volumeBindingMode: WaitForFirstConsumer
---
EOF
kubectl apply -f $HARBOR/harbor-sc.yaml -n clt-devops
#create volume
cat <<EOF > $HARBOR/harbor-pv.yaml
---
apiVersion: v1
kind: PersistentVolume
metadata:
  name: harbor-registry-pv
  namespace: clt-devops
spec:
  storageClassName: harbor-registry-sc
  accessModes:
  - ReadWriteOnce
  capacity:
    storage: 20Gi
  persistentVolumeReclaimPolicy: Retain
  hostPath:
    path: /data/harbor-registry/
  nodeAffinity:
    required:
      nodeSelectorTerms:
        - matchExpressions:
            - key: kubernetes.io/hostname
              operator: In
              values:
                - node1
---
apiVersion: v1
kind: PersistentVolume
metadata:
  name: harbor-cm-pv
  namespace: clt-devops
spec:
  storageClassName: harbor-cm-sc
  accessModes:
  - ReadWriteOnce
  capacity:
    storage: 20Gi
  persistentVolumeReclaimPolicy: Retain
  hostPath:
    path: /data/harbor-cm/
  nodeAffinity:
    required:
      nodeSelectorTerms:
        - matchExpressions:
            - key: kubernetes.io/hostname
              operator: In
              values:
                - node1
---
apiVersion: v1
kind: PersistentVolume
metadata:
  name: harbor-js-pv
  namespace: clt-devops
spec:
  storageClassName: harbor-js-sc
  accessModes:
  - ReadWriteOnce
  capacity:
    storage: 5Gi
  persistentVolumeReclaimPolicy: Retain
  hostPath:
    path: /data/harbor-js/
  nodeAffinity:
    required:
      nodeSelectorTerms:
        - matchExpressions:
            - key: kubernetes.io/hostname
              operator: In
              values:
                - node1
---
apiVersion: v1
kind: PersistentVolume
metadata:
  name: harbor-db-pv
  namespace: clt-devops
spec:
  storageClassName: harbor-db-sc
  accessModes:
  - ReadWriteOnce
  capacity:
    storage: 5Gi
  persistentVolumeReclaimPolicy: Retain
  hostPath:
    path: /data/harbor-db/
  nodeAffinity:
    required:
      nodeSelectorTerms:
        - matchExpressions:
            - key: kubernetes.io/hostname
              operator: In
              values:
                - node1
---
apiVersion: v1
kind: PersistentVolume
metadata:
  name: harbor-redis-pv
  namespace: clt-devops
spec:
  storageClassName: harbor-redis-sc
  accessModes:
  - ReadWriteOnce
  capacity:
    storage: 5Gi
  persistentVolumeReclaimPolicy: Retain
  hostPath:
    path: /data/harbor-redis/
  nodeAffinity:
    required:
      nodeSelectorTerms:
        - matchExpressions:
            - key: kubernetes.io/hostname
              operator: In
              values:
                - node1
---
apiVersion: v1
kind: PersistentVolume
metadata:
  name: harbor-trivy-pv
  namespace: clt-devops
spec:
  storageClassName: harbor-trivy-sc
  accessModes:
  - ReadWriteOnce
  capacity:
    storage: 5Gi
  persistentVolumeReclaimPolicy: Retain
  hostPath:
    path: /data/harbor-trivy/
  nodeAffinity:
    required:
      nodeSelectorTerms:
        - matchExpressions:
            - key: kubernetes.io/hostname
              operator: In
              values:
                - node1
---
EOF
kubectl apply -f $HARBOR/harbor-pv.yaml -n clt-devops

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
kubectl apply -f $HARBOR/certmanager-crds.yaml -n clt-devops
kubectl label namespace clt-devops certmanager.k8s.io/disable-validation=true
helm repo add jetstack https://charts.jetstack.io
helm install cert-manager --namespace clt-devops jetstack/cert-manager

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
helm install harbor harbor/harbor -n clt-devops \
--set \
expose.type=ingress,\
expose.tls.secret.secretName=default-server-secret,\
expose.ingress.hosts.core=core.harbor.domain,\
expose.ingress.hosts.notary=notary.harbor.domain,\
externalURL=30.0.2.30,\
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