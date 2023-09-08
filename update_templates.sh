#!/bin/zsh

time ansible-playbook -i hosts.yml playbooks/update_templates.yml --vault-password-file=./.pass