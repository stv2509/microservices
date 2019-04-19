#!/bin/bash
if gcloud compute firewall-rules list --format=json | grep cadvisor
then
	echo -e "\n #######- Firewall-rules \"default-allow-cadvisor\" alredy install -#######\n\n"
else
	echo -e "#######- INSTALL default-allow-cadvisor -#######\n"
	gcloud compute firewall-rules create default-allow-cadvisor \
 --allow tcp:8080 --priority=65534 \
 --description="Allows cAdvisor connections" \
 --direction=INGRESS
	echo -e "\n#######- Installation completed -#######\n\n"
fi


if gcloud compute firewall-rules list --format=json | grep grafana
then
	echo -e "\n #######- Firewall-rules \"default-allow-grafana\" alredy install -#######\n\n"
else
	echo -e "#######- INSTALL default-allow-grafana -#######\n"
	gcloud compute firewall-rules create default-allow-grafana \
 --allow tcp:3000 --priority=65534 \
 --description="Allows Grafana connections" \
 --direction=INGRESS
	echo -e "\n#######- Installation completed -#######"
fi



if gcloud compute firewall-rules list --format=json | grep alertmanager
then
	echo -e "\n #######- Firewall-rules \"default-allow-alertmanager\" alredy install -#######\n\n"
else
	echo -e "#######- INSTALL default-allow-alertmanager -#######\n"
	gcloud compute firewall-rules create default-allow-alertmanager \
 --allow tcp:9093 --priority=65534 \
 --description="Allows Alertmanager connections" \
 --direction=INGRESS
	echo -e "\n#######- Installation completed -#######"
fi


if gcloud compute firewall-rules list --format=json | grep efkstack
then
	echo -e "\n #######- Firewall-rules \"default-allow-efkstack\" alredy install -#######\n\n"
else
	echo -e "#######- INSTALL default-allow-efkstak -#######\n"
	gcloud compute firewall-rules create default-allow-efk \
 --allow tcp:24224,tcp:9200,tcp:5601 --priority=65534 \
 --description="Allows EFKStack connections" \
 --direction=INGRESS
	echo -e "\n#######- Installation completed -#######"
fi
