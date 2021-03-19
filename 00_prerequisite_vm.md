---
layout: post
title:  "Kafka Cluster mission"
---
#####Pre-requisite
 - VirtualBox (https://www.virtualbox.org/) 
 - MobaXTerm (https://mobaxterm.mobatek.net/download.html)
 
 
###### VirtualBox
Do below process in VB.<br>
0. File -> Preference -> Network
- Network Name: NatNetwork
- Network CIDR: 30.0.2.0/24
- Network Option: DHCP Enable
- Port-Forwarding:add belows
<img src="/resources/vb_network.png" width=300, heigth=400>

1. Create VM
- VM name: master
- RAM: 3096 MB
- HDD: 50Gi, VDI, Dynamic Allocation

2. Setting -> System -> Processor
- Processor: 2

3. Setting -> Network -> Adapter1
-NAT Network

4. Run VM

5. Install CentOS
- language:Korean
- network and host:
  [H\]: master
  [Setting-General\] - (A): Check
  [IPv4\] -<br> (M):Manual
  (Address): IP 30.0.2.30, NetMask: 255.255.255.0, Gateway: 30.0.2.1, DNS: 8.8.8.8
- set root password 

