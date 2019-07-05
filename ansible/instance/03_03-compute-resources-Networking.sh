#!/bin/bash


echo "##- Create the kubernetes-the-hard-way custom VPC network -##"
gcloud compute networks create kubernetes-the-hard-way --subnet-mode custom
echo "Sucsess...."

echo "##- Create the kubernetes subnet in the kubernetes-the-hard-way VPC network -##"
gcloud compute networks subnets create kubernetes \
            --network kubernetes-the-hard-way \
	    --range 10.240.0.0/24
echo "Sucsess...."

echo "###- Firewall Rules -###"
echo "##- Create a firewall rule that allows internal communication across all protocols -##"
gcloud compute firewall-rules create kubernetes-the-hard-way-allow-internal \
	  --allow tcp,udp,icmp \
          --network kubernetes-the-hard-way \
          --source-ranges 10.240.0.0/24,10.200.0.0/16
echo "Sucsess...."


echo "##- Create a firewall rule that allows external SSH, ICMP, and HTTPS -##"
gcloud compute firewall-rules create kubernetes-the-hard-way-allow-external \
	  --allow tcp:22,tcp:6443,icmp \
          --network kubernetes-the-hard-way \
          --source-ranges 0.0.0.0/0
echo "Sucsess...."

echo "##- List the firewall rules in the kubernetes-the-hard-way VPC network -##"
echo $(gcloud compute firewall-rules list --filter="network:kubernetes-the-hard-way" --format=)

echo "##- Kubernetes Public IP Address -##"
gcloud compute addresses create kubernetes-the-hard-way \
	  --region $(gcloud config get-value compute/region)

echo "##- Verify the kubernetes-the-hard-way static IP address was created in your default compute region -##"
echo "$(gcloud compute addresses list --filter="name=('kubernetes-the-hard-way')")"

