kubectl create namespace kube-repo

ssh 30.0.2.31 -y #Node1 access
for i in 1 2 3
do
mkdir -p /database/postgre$i
chmod 777 /database/postgre$i
done
exit