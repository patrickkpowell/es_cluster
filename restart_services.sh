#!/bin/zsh

time ansible-playbook -i hosts.yml playbooks/restart_services.yml -e @group_vars/vault.yml --vault-password-file=./.pass