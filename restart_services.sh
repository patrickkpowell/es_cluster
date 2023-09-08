#!/bin/zsh

time ansible-playbook -i hosts.yml playbooks/restart_services.yml --vault-password-file=./.pass