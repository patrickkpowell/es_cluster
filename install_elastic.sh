#!/bin/zsh

time ansible-playbook -i hosts.yml playbooks/deploy_es_cluster.yml -e @group_vars/vault.yml --vault-password-file=./.pass --tags create