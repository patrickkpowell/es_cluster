#!/bin/zsh

time ansible-playbook -i hosts.yml playbooks/reset_es_pw.yml --vault-password-file=./.pass --tags resetpw