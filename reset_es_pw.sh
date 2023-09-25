#!/bin/zsh

time ansible-playbook -i hosts.yml playbooks/reset_es_pw.yml -e @group_vars/vault.yml --vault-password-file=./.pass --tags resetpw