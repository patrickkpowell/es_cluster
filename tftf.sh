#!/bin/zsh

time ansible-playbook -i tftf_inventory.yml playbooks/deploy_es_cluster.yml  -e @group_vars/vault.yml --vault-password-file=./.pass --tags create && ./ntfy_success.sh || ./ntfy_fail.sh

