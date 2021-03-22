## Jenkins reference: https://twofootdog.tistory.com/11
kubectl create namespace clt-devops
JENKINS=./cicd/jenkins

# create RBAC
cat <<EOF > jenkins-sa-clusteradmin-rbac.yaml
apiVersion: v1
kind: ServiceAccount
metadata:
  namespace: clt-devops
  name: jenkins

---

kind: ClusterRoleBinding
apiVersion: rbac.authorization.k8s.io/v1
metadata:
  name: cluster-admin-clusterrolebinding
subjects:
- kind: ServiceAccount
  name: jenkins
  namespace: clt-devops
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: cluster-admin

---

kind: ClusterRoleBinding
apiVersion: rbac.authorization.k8s.io/v1
metadata:
  name: cluster-admin-clusterrolebinding-2
subjects:
- kind: ServiceAccount
  name: default
  namespace: clt-devops
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: cluster-admin
EOF
kubectl apply -f jenkins-sa-clusteradmin-rbac.yaml -n clt-devops

# create jenkins volume
ssh 30.0.2.31 -y #Node1 access
mkdir -p /data/jenkins-volume
chmod 777 /data/jenkins-volume
exit #Exit from node

mkdir -p $JENKINS
cat <<EOF > $JENKINS/jenkins-storageclass.yaml
---
kind: StorageClass
apiVersion: storage.k8s.io/v1
metadata:
  name: jenkins-sc
  namespace: clt-devops
provisioner: kubernetes.io/no-provisioner
volumeBindingMode: WaitForFirstConsumer
EOF
kubectl apply -f $JENKINS/jenkins-storageclass.yaml

cat <<EOF > $JENKINS/jenkins-volume.yaml
apiVersion: v1
kind: PersistentVolume
metadata:
  name: jenkins-pv
  namespace: clt-devops
spec:
  storageClassName: jenkins-sc
  accessModes:
  - ReadWriteOnce
  capacity:
    storage: 20Gi
  persistentVolumeReclaimPolicy: Retain
  hostPath:
    path: /data/jenkins-volume/
  nodeAffinity:
    required:
      nodeSelectorTerms:
        - matchExpressions:
            - key: kubernetes.io/hostname
              operator: In
              values:
                - node1
EOF
kubectl apply -f $JENKINS/jenkins-volume.yaml

cat <<EOF > $JENKINS/jenkins-pvc.yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: jenkins-pvc
  namespace: clt-devops
spec:
  storageClassName: jenkins-sc
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 20Gi
EOF
kubectl apply -f $JENKINS/jenkins-pvc.yaml -n clt-devops

cat <<EOF > $JENKINS/jenkins-svc.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: jenkins-leader
  namespace: clt-devops
spec:
  replicas: 1
  selector:
    matchLabels:
      app: jenkins-leader
  template:
    metadata:
      labels:
        app: jenkins-leader
    spec:
      serviceAccountName: jenkins
      securityContext: # Jenkins uid:gid=1000:1000
        fsGroup: 1000
      containers:
        - name: jenkins-leader
          image: jenkins/jenkins:alpine
          volumeMounts:
          - name: jenkins-home
            mountPath: /var/jenkins_home
          ports:
          - containerPort: 8080
          - containerPort: 50000
      volumes:
        - name: jenkins-home
          emptyDir: {}
#          persistentVolumeClaim:
#            claimName: jenkins-pvc
      nodeSelector:
        kubernetes.io/hostname: node1
---
apiVersion: v1
kind: Service
metadata:
  name: jenkins-leader-svc
  namespace: clt-devops
  labels:
    app: jenkins-leader
spec:
  type: LoadBalancer
  ports:
  - port: 80
    targetPort: 8080
    protocol: TCP
    name: http
  - port: 50000
    protocol: TCP
    name: slave
  selector:
    app: jenkins-leader
---
EOF
kubectl apply -f $JENKINS/jenkins-svc.yaml -n clt-devops