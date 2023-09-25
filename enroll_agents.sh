#!/bin/bash

time ansible-playbook -i hosts.yml playbooks/enroll_agents.yml -e @group_vars/vault.yml --vault-password-file=./.pass --tags fleet
