#!/bin/zsh

time ansible-playbook -i hosts.yml playbooks/install_elastic.yml -e @group_vars/vault.yml --vault-password-file=./.pass --tags create