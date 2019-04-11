#!/bin/bash
if gcloud compute firewall-rules list --format=json | grep reddit
then
	echo -e "\n #######- Firewall-rules \"reddit-app\" alredy nstall -#######"
else
	echo -e "#######- INSTALL default-allow-reddit-app -#######\n"
	gcloud compute firewall-rules create reddit-app \
 --allow tcp:9292 --priority=65534 \
 --description="Allows reddit-app connections" \
 --direction=INGRESS --target-tags=docker-machine
	echo -e "\n#######- Installation completed -#######"
fi
