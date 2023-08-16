provision_vms
=========

Installs and updates packages.  Currently disables selinux.  Reboots if necessary.

Requirements
------------


Role Variables
--------------

  packages:
    - 'qemu-guest-agent'
    - '...'

Dependencies
------------


Example Playbook
----------------

    - hosts: esnodes
      gather_facts: false
      roles:
         - roles/provision_vms

License
-------

BSD

Author Information
------------------

Patrick Powell
