#!/bin/bash

exec 1> docker-compose.yml

printf "
---
version: '3.5'
services:
  web:
    image: 'gitlab/gitlab-ce:latest'
    restart: always
    hostname: 'gitlab.example.com'
    environment:
      GITLAB_OMNIBUS_CONFIG: |
          external_url 'http://$(terraform output -state="/vagrant_data/microservices/gitlab-ci/terraform/stage/terraform.tfstate" gitlab_external_ip)'
    ports:
      - '80:80'
      - '443:443'
      - '2222:22'
    volumes:
      - '/srv/gitlab/config:/etc/gitlab'
      - '/srv/gitlab/logs:/var/log/gitlab'
      - '/srv/gitlab/data:/var/opt/gitlab'
"
