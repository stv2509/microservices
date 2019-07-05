#!/bin/bash

KUBERNETES_PUBLIC_ADDRESS=$(gcloud compute addresses describe kubernetes-the-hard-way \
	  --region $(gcloud config get-value compute/region) \
	    --format 'value(address)')

echo "##- The kubelet Kubernetes Configuration File -##"
{
for instance in worker-0 worker-1 worker-2; do
  kubectl config set-cluster kubernetes-the-hard-way \
    --certificate-authority=ca.pem \
    --embed-certs=true \
    --server=https://${KUBERNETES_PUBLIC_ADDRESS}:6443 \
    --kubeconfig=${instance}.kubeconfig

  kubectl config set-credentials system:node:${instance} \
    --client-certificate=${instance}.pem \
    --client-key=${instance}-key.pem \
    --embed-certs=true \
    --kubeconfig=${instance}.kubeconfig

  kubectl config set-context default \
    --cluster=kubernetes-the-hard-way \
    --user=system:node:${instance} \
    --kubeconfig=${instance}.kubeconfig

  kubectl config use-context default --kubeconfig=${instance}.kubeconfig
done
}

if [[ -e ./worker-0.kubeconfig ]] && [[ -e ./worker-1.kubeconfig ]] && [[ -e ./worker-2.kubeconfig ]]
then
    echo -e "Sucsess....\n
    Results:\n\n

    worker-0.kubeconfig\n
    worker-1.kubeconfig\n
    worker-2.kubeconfig\n"
else
   echo "\nError...\n"
fi

###################################################################################################
echo "##- The kube-proxy Kubernetes Configuration File -##"
{
  kubectl config set-cluster kubernetes-the-hard-way \
    --certificate-authority=ca.pem \
    --embed-certs=true \
    --server=https://${KUBERNETES_PUBLIC_ADDRESS}:6443 \
    --kubeconfig=kube-proxy.kubeconfig

  kubectl config set-credentials system:kube-proxy \
    --client-certificate=kube-proxy.pem \
    --client-key=kube-proxy-key.pem \
    --embed-certs=true \
    --kubeconfig=kube-proxy.kubeconfig

  kubectl config set-context default \
    --cluster=kubernetes-the-hard-way \
    --user=system:kube-proxy \
    --kubeconfig=kube-proxy.kubeconfig

  kubectl config use-context default --kubeconfig=kube-proxy.kubeconfig
}

if [[ -e ./kube-proxy.kubeconfig ]]
then
    echo -e "Sucsess....\n
    Results:\n\n

    kube-proxy.kubeconfig\n"
else
   echo "\nError...\n"
fi

###################################################################################################
echo "##- The kube-controller-manager Kubernetes Configuration File -##"
{
  kubectl config set-cluster kubernetes-the-hard-way \
    --certificate-authority=ca.pem \
    --embed-certs=true \
    --server=https://127.0.0.1:6443 \
    --kubeconfig=kube-controller-manager.kubeconfig

  kubectl config set-credentials system:kube-controller-manager \
    --client-certificate=kube-controller-manager.pem \
    --client-key=kube-controller-manager-key.pem \
    --embed-certs=true \
    --kubeconfig=kube-controller-manager.kubeconfig

  kubectl config set-context default \
    --cluster=kubernetes-the-hard-way \
    --user=system:kube-controller-manager \
    --kubeconfig=kube-controller-manager.kubeconfig

  kubectl config use-context default --kubeconfig=kube-controller-manager.kubeconfig
}

if [[ -e ./kube-controller-manager.kubeconfig ]]
then
    echo -e "Sucsess....\n
    Results:\n\n

    kube-controller-manager.kubeconfig\n"
else
   echo "\nError...\n"
fi

###################################################################################################
echo "##- The kube-scheduler Kubernetes Configuration File -##"
{
  kubectl config set-cluster kubernetes-the-hard-way \
    --certificate-authority=ca.pem \
    --embed-certs=true \
    --server=https://127.0.0.1:6443 \
    --kubeconfig=kube-scheduler.kubeconfig

  kubectl config set-credentials system:kube-scheduler \
    --client-certificate=kube-scheduler.pem \
    --client-key=kube-scheduler-key.pem \
    --embed-certs=true \
    --kubeconfig=kube-scheduler.kubeconfig

  kubectl config set-context default \
    --cluster=kubernetes-the-hard-way \
    --user=system:kube-scheduler \
    --kubeconfig=kube-scheduler.kubeconfig

  kubectl config use-context default --kubeconfig=kube-scheduler.kubeconfig
}

if [[ -e ./kube-scheduler.kubeconfig ]]
then
    echo -e "Sucsess....\n
    Results:\n\n

    kube-scheduler.kubeconfig\n"
else
   echo "\nError...\n"
fi

###################################################################################################
echo "##- The admin Kubernetes Configuration File -##"
{
  kubectl config set-cluster kubernetes-the-hard-way \
    --certificate-authority=ca.pem \
    --embed-certs=true \
    --server=https://127.0.0.1:6443 \
    --kubeconfig=admin.kubeconfig

  kubectl config set-credentials admin \
    --client-certificate=admin.pem \
    --client-key=admin-key.pem \
    --embed-certs=true \
    --kubeconfig=admin.kubeconfig

  kubectl config set-context default \
    --cluster=kubernetes-the-hard-way \
    --user=admin \
    --kubeconfig=admin.kubeconfig

  kubectl config use-context default --kubeconfig=admin.kubeconfig
}

if [[ -e ./admin.kubeconfig ]]
then
    echo -e "Sucsess....\n
    Results:\n\n

    admin.kubeconfig\n"
else
   echo "\nError...\n"
fi

