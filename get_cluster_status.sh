#!/bin/zsh

time ansible-playbook -i hosts.yml playbooks/get_cluster_status.yml --vault-password-file=./.pass --tags status