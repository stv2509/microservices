#!/bin/bash

#################################################################
echo "##- Install CFSSL -##"
wget -c -q  --https-only --timestamping \
	    https://pkg.cfssl.org/R1.2/cfssl_linux-amd64 \
	    https://pkg.cfssl.org/R1.2/cfssljson_linux-amd64

chmod +x ./cfssl_linux-amd64 ./cfssljson_linux-amd64
sudo mv -f ./cfssl_linux-amd64 /usr/local/bin/cfssl
sudo mv -f ./cfssljson_linux-amd64 /usr/local/bin/cfssljson
echo "Sucsess...."


#################################################################
echo "##- Install kubectl binary with curl on Linux -##"
curl -LO https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl
chmod +x ./kubectl
sudo mv -f ./kubectl /usr/local/bin/
echo "##- Verification kubectl client -##"
echo $(kubectl version --client)
echo "Sucsess...."


#################################################################
echo "##- Google Cloud Platform-##"
echo "##- Set a Default Compute Region and Zone -##"
gcloud config set compute/region europe-west1
gcloud config set compute/zone europe-west1-b
echo "Sucsess...."
