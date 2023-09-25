#!/bin/zsh

time ansible-playbook -i hosts.yml playbooks/deploy_agents.yml -e @group_vars/vault.yml --vault-password-file=./.pass --tags create