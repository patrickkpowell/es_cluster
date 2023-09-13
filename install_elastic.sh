#!/bin/zsh

time ansible-playbook -i hosts.yml playbooks/install_elastic.yml --vault-password-file=./.pass --tags create