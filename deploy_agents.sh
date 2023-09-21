#!/bin/zsh

time ansible-playbook -i hosts.yml playbooks/deploy_agents.yml --vault-password-file=./.pass --tags create