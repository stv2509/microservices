#!/bin/bash

echo -e "\nPrint the internal IP address and Pod CIDR range for each worker instance:\n"
{
for instance in worker-0 worker-1 worker-2; do
  gcloud compute instances describe ${instance} \
    --format 'value[separator=" "](networkInterfaces[0].networkIP,metadata.items[0].value)'
done
}

echo -e "\nCreate network routes for each worker instance:\n"
{
for i in 0 1 2; do
  gcloud compute routes create kubernetes-route-10-200-${i}-0-24 \
    --network kubernetes-the-hard-way \
    --next-hop-address 10.240.0.2${i} \
    --destination-range 10.200.${i}.0/24
done
}

echo -e "\nList the routes in the kubernetes-the-hard-way VPC network:\n"
{
gcloud compute routes list --filter "network: kubernetes-the-hard-way"
}
echo -e "\nSuccess....\n"
