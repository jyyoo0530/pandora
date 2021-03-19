# this
setenforce 0
# this
sed -i 's/^SELINUX=enforcing$/SELINUX=permissive/' /etc/selinux/config
# (optional) check status
sestatus
# this
systemctl stop firewalld && systemctl disable firewalld
# this
systemctl stop NetworkManager && systemctl disable NetworkManager
# this
swapoff -a && sed -i '/ swap / s/^/#/' /etc/fstab
# this
cat <<EOF >  /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
EOF
sysctl --system

echo '1' > /proc/sys/net/ipv4/ip_forward
# this
cat <<EOF > /etc/yum.repos.d/kubernetes.repo
[kubernetes]
name=Kubernetes
baseurl=https://packages.cloud.google.com/yum/repos/kubernetes-el7-x86_64
enabled=1
gpgcheck=1
repo_gpgcheck=1
gpgkey=https://packages.cloud.google.com/yum/doc/yum-key.gpg https://packages.cloud.google.com/yum/doc/rpm-package-key.gpg
exclude=kubelet kubeadm kubectl
EOF
# this
yum -y update
# this
cat <<EOF >> /etc/hosts
30.0.2.30 master
30.0.2.31 node1
30.0.2.32 node2
30.0.2.33 node3
EOF
# this
yum install -y yum-utils device-mapper-persistent-data lvm2
# this
yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
# this
yum update -y && yum install -y containerd.io-1.2.13 docker-ce-19.03.11 docker-ce-cli-19.03.11
# this
mkdir /etc/docker

cat > /etc/docker/daemon.json <<EOF
{
  "exec-opts": ["native.cgroupdriver=systemd"],
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "100m"
  },
  "storage-driver": "overlay2",
  "storage-opts": [
    "overlay2.override_kernel_check=true"
  ]
}
EOF

mkdir -p /etc/systemd/system/docker.service.d
# this
yum install -y --disableexcludes=kubernetes kubeadm-1.20.4-0.x86_64 kubectl-1.20.4-0.x86_64 kubelet-1.20.4-0.x86_64
# this
systemctl enable docker.service
systemctl enable kubelet.service
systemctl start docker.service
## additional softwares
#nano
yum install nano -y
#helm
curl https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3 > get_helm.sh
chmod 700 get_helm.sh
./get_helm.sh