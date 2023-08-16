#!/bin/zsh

time ansible-playbook -i hosts.yml playbooks/deploy_es_cluster.yml --vault-password-file=./.pass --tags destroy
