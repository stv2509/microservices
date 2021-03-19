#!/bin/bash

echo "####- Certificate Authority -####"
echo -e "##- Certificate Authority -##\n"
echo "#- Generate the CA configuration file, certificate, and private key -#"

{

cat > ca-config.json <<EOF
{
  "signing": {
    "default": {
      "expiry": "8760h"
    },
    "profiles": {
      "kubernetes": {
        "usages": ["signing", "key encipherment", "server auth", "client auth"],
        "expiry": "8760h"
      }
    }
  }
}
EOF

cat > ca-csr.json <<EOF
{
  "CN": "Kubernetes",
  "key": {
    "algo": "rsa",
    "size": 2048
  },
  "names": [
    {
      "C": "US",
      "L": "Portland",
      "O": "Kubernetes",
      "OU": "CA",
      "ST": "Oregon"
    }
  ]
}
EOF

cfssl gencert -initca ca-csr.json | cfssljson -bare ca

}

if [[ -e ./ca-config.json ]] && [[ -e ./ca-csr.json ]]
then
    echo -e "Sucsess....\n
    Results:\n\n

    ca-key.pem\n
    ca.pem\n"
else
   echo "Error...\n"
fi

###################################################################################################
echo "#- Generate the admin client certificate and private key -#"

{

cat > admin-csr.json <<EOF
{
  "CN": "admin",
  "key": {
    "algo": "rsa",
    "size": 2048
  },
  "names": [
    {
      "C": "US",
      "L": "Portland",
      "O": "system:masters",
      "OU": "Kubernetes The Hard Way",
      "ST": "Oregon"
    }
  ]
}
EOF

cfssl gencert \
  -ca=ca.pem \
  -ca-key=ca-key.pem \
  -config=ca-config.json \
  -profile=kubernetes \
  admin-csr.json | cfssljson -bare admin

}

if [[ -e ./admin-key.pem ]] && [[ -e ./admin.pem ]]
then
    echo -e "Sucsess....\n
    Results:\n\n

    admin-key.pem\n
    admin.pem\n"

else
   echo "Error...\n"
fi


###################################################################################################
echo "#- Generate a certificate and private key for each Kubernetes worker node -#"

for instance in worker-0 worker-1 worker-2; do
cat > ${instance}-csr.json <<EOF
{
  "CN": "system:node:${instance}",
  "key": {
    "algo": "rsa",
    "size": 2048
  },
  "names": [
    {
      "C": "US",
      "L": "Portland",
      "O": "system:nodes",
      "OU": "Kubernetes The Hard Way",
      "ST": "Oregon"
    }
  ]
}
EOF

EXTERNAL_IP=$(gcloud compute instances describe ${instance} \
  --format 'value(networkInterfaces[0].accessConfigs[0].natIP)')

INTERNAL_IP=$(gcloud compute instances describe ${instance} \
  --format 'value(networkInterfaces[0].networkIP)')

cfssl gencert \
  -ca=ca.pem \
  -ca-key=ca-key.pem \
  -config=ca-config.json \
  -hostname=${instance},${EXTERNAL_IP},${INTERNAL_IP} \
  -profile=kubernetes \
  ${instance}-csr.json | cfssljson -bare ${instance}
done

if [[ -e ./worker-0-key.pem ]] && [[ -e ./worker-0.pem ]] && [[ -f ./worker-1-key.pem ]] && [[ -f ./worker-1.pem ]] && [[ -f ./worker-2-key.pem ]] && [[ -f ./worker-2.pem ]]
then
    echo -e "Sucsess....\n
    Results:\n\n

    worker-0-key.pem\n
    worker-0.pem\n
    worker-1-key.pem\n
    worker-1.pem\n
    worker-2-key.pem\n
    worker-2.pem\n"
else
   echo "Error...\n"
fi


###################################################################################################
echo "#- Generate the kube-controller-manager client certificate and private key -#"

{

cat > kube-controller-manager-csr.json <<EOF
{
  "CN": "system:kube-controller-manager",
  "key": {
    "algo": "rsa",
    "size": 2048
  },
  "names": [
    {
      "C": "US",
      "L": "Portland",
      "O": "system:kube-controller-manager",
      "OU": "Kubernetes The Hard Way",
      "ST": "Oregon"
    }
  ]
}
EOF

cfssl gencert \
  -ca=ca.pem \
  -ca-key=ca-key.pem \
  -config=ca-config.json \
  -profile=kubernetes \
  kube-controller-manager-csr.json | cfssljson -bare kube-controller-manager

}

if [[ -e ./kube-controller-manager-key.pem ]] && [[ -e ./kube-controller-manager.pem ]]
then
    echo -e "Sucsess....\n
    Results:\n\n

    kube-controller-manager-key.pem\n
    kube-controller-manager.pem\n"

else
   echo "Error...\n"
fi


###################################################################################################
echo "#- Generate the kube-proxy client certificate and private key -#"

{

cat > kube-proxy-csr.json <<EOF
{
  "CN": "system:kube-proxy",
  "key": {
    "algo": "rsa",
    "size": 2048
  },
  "names": [
    {
      "C": "US",
      "L": "Portland",
      "O": "system:node-proxier",
      "OU": "Kubernetes The Hard Way",
      "ST": "Oregon"
    }
  ]
}
EOF

cfssl gencert \
  -ca=ca.pem \
  -ca-key=ca-key.pem \
  -config=ca-config.json \
  -profile=kubernetes \
  kube-proxy-csr.json | cfssljson -bare kube-proxy

}

if [[ -e ./kube-proxy-key.pem ]] && [[ -e ./kube-proxy.pem ]]
then
    echo -e "Sucsess....\n
    Results:\n\n

    kube-proxy-key.pem\n
    kube-proxy.pem\n"

else
   echo "Error...\n"
fi


###################################################################################################
echo "#- Generate the kube-scheduler client certificate and private key -#"

{

cat > kube-scheduler-csr.json <<EOF
{
  "CN": "system:kube-scheduler",
  "key": {
    "algo": "rsa",
    "size": 2048
  },
  "names": [
    {
      "C": "US",
      "L": "Portland",
      "O": "system:kube-scheduler",
      "OU": "Kubernetes The Hard Way",
      "ST": "Oregon"
    }
  ]
}
EOF

cfssl gencert \
  -ca=ca.pem \
  -ca-key=ca-key.pem \
  -config=ca-config.json \
  -profile=kubernetes \
  kube-scheduler-csr.json | cfssljson -bare kube-scheduler

}

if [[ -e ./kube-scheduler-key.pem ]] && [[ -e ./kube-scheduler.pem ]]
then
    echo -e "Sucsess....\n
    Results:\n\n

    kube-scheduler-key.pem\n
    kube-scheduler.pem\n"

else
   echo "Error...\n"
fi

###################################################################################################
echo "Generate the Kubernetes API Server certificate and private key"

{

KUBERNETES_PUBLIC_ADDRESS=$(gcloud compute addresses describe kubernetes-the-hard-way \
  --region $(gcloud config get-value compute/region) \
  --format 'value(address)')

cat > kubernetes-csr.json <<EOF
{
  "CN": "kubernetes",
  "key": {
    "algo": "rsa",
    "size": 2048
  },
  "names": [
    {
      "C": "US",
      "L": "Portland",
      "O": "Kubernetes",
      "OU": "Kubernetes The Hard Way",
      "ST": "Oregon"
    }
  ]
}
EOF

cfssl gencert \
  -ca=ca.pem \
  -ca-key=ca-key.pem \
  -config=ca-config.json \
  -hostname=10.32.0.1,10.240.0.10,10.240.0.11,10.240.0.12,${KUBERNETES_PUBLIC_ADDRESS},127.0.0.1,kubernetes.default \
  -profile=kubernetes \
  kubernetes-csr.json | cfssljson -bare kubernetes

}

if [[ -e ./kubernetes-key.pem ]] && [[ -e ./kubernetes.pem ]]
then
    echo -e "Sucsess....\n
    Results:\n\n

    kubernetes-key.pem\n
    kubernetes.pem\n"
else
   echo "Error...\n"
fi


###################################################################################################
echo "Generate the service-account certificate and private key"

{

cat > service-account-csr.json <<EOF
{
  "CN": "service-accounts",
  "key": {
    "algo": "rsa",
    "size": 2048
  },
  "names": [
    {
      "C": "US",
      "L": "Portland",
      "O": "Kubernetes",
      "OU": "Kubernetes The Hard Way",
      "ST": "Oregon"
    }
  ]
}
EOF

cfssl gencert \
  -ca=ca.pem \
  -ca-key=ca-key.pem \
  -config=ca-config.json \
  -profile=kubernetes \
  service-account-csr.json | cfssljson -bare service-account

}

if [[ -e ./service-account-key.pem ]] && [[ -e ./service-account.pem ]]
then
    echo -e "Sucsess....\n
    Results:\n\n
    
    service-account-key.pem\n
    service-account.pem\n"

else
   echo "Error...\n"
fi



###################################################################################################
echo -e "\nSCRIPT SUCSESS....\n\n"
