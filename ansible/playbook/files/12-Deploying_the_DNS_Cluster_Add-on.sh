#!/bin/bash

echo -e "\nDeploy the coredns cluster add-on:\n"
{
kubectl apply -f https://storage.googleapis.com/kubernetes-the-hard-way/coredns.yaml
}

echo -e "\nList the pods created by the kube-dns deployment:\n"
{
kubectl get pods -l k8s-app=kube-dns -n kube-system
}
echo -e "\nSuccess....\n"
