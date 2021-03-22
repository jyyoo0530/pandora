KAFKA=./cicd/kafka
mkdir -p $KAFKA

ssh 30.0.2.31 -y #Node1 access
for i in 1 2 3
do
mkdir -p /database/kafka/kafka$i
chmod 777 /database/kafka/kafka$i
mkdir -p /database/kafka/zookeeper$i
chmod 777 /database/kafka/zookeeper$i
done
exit

curl -o $KAFKA/kafkaoperator.yaml https://strimzi.io/install/latest?namespace=clt-datacenter
#add kafka app in argo
kubectl create -f $KAFKA/kafkaoperator.yaml -n clt-datacenter