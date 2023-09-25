#!/bin/zsh

time ansible-playbook -i hosts.yml playbooks/get_cluster_status.yml -e @group_vars/vault.yml --vault-password-file=./.pass --tags status