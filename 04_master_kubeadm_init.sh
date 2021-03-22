# initiate cluster
rm -f ~/.kube/config
rm -f /etc/cni/net.d/*
sudo kubeadm init --apiserver-advertise-address=$(hostname -I | cut -d' ' -f1) --pod-network-cidr=10.244.0.0/16

# enable kubectl
sudo rm $HOME/.kube/config
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config

# wait for cluster initiation -----> enchancement required.
kubectl wait pod/kube-controller-manager-master --for=condition=Ready --timeout=300s -n kube-system
mkdir -p ~/pandora
cd ~/pandora

## run pod-operator
# 1) flannel
mkdir -p ./podoperator/flannel
curl -o ./podoperator/flannel/flannel.yaml https://raw.githubusercontent.com/coreos/flannel/master/Documentation/kube-flannel.yml
kubectl apply -f ./podoperator/flannel/flannel.yaml

