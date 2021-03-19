## repeat below for each of your nodes.
# this
vi /etc/sysconfig/network-scripts/ifcfg-enp0s3
# change below to appropriate IP address
...
IPADDR="30.0.2.31"
...
# this
systemctl restart network
# set appropriate hostname.
hostnamectl set-hostname node1