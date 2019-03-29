#!/bin/bash

terraform import module.vpc.google_compute_firewall.firewall_ssh default-allow-ssh
terraform import module.vpc.google_compute_firewall.firewall_https default-allow-https
terraform import module.vpc.google_compute_firewall.firewall_http default-allow-http
