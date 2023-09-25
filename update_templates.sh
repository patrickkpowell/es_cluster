#!/bin/zsh

time ansible-playbook -i hosts.yml playbooks/update_templates.yml -e @group_vars/vault.yml --vault-password-file=./.pass