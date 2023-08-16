manage_vms
=========

Deploy's VM's from template and sets mac address.  This is intended to leverage dhcp reservations elsewhere in your infrastructure.  Currently only ProxMox is supported using community.general.proxmox_* modules.

Requirements
------------
Need to use ansible vault to generate values for variables.  See defaults/main.yml for example.  It is reccomended that these be overridden in group_vars/all.
DHCP reservations and DNS enreies should be made for the mac values listed in the vm's dictionary.
community.general.proxmox_* modules

Future plans to extend for vmware using vmware_guest modules.

Role Variables
--------------

  api_user: 'user'\
  api_pass: 'password'\
  api_host: 'cluster or host'\
  api_port: '8006 default for ProxMox'\
  vm_template: 'VM template to clone from'\
  vm_node: 'Node in cluster to perform operations'\
  vm_cores: 'CPU cores'\
  vm_memory: 'Amount of RAM (ex. 4096)'\
  vm_disk_size: 'Disk six (ex. 20G)'\
  vms:\
    - {name: 'es01', interface: 'net0', nic: 'virtio', bridge: 'vmbr0', mac: '0a:1b:2c:3d:4e:5f'}\
    - {name: 'es02', interface: 'net0', nic: 'virtio', bridge: 'vmbr0', mac: '0a:1b:2c:3d:4e:5a'}\
    - {name: 'es03', interface: 'net0', nic: 'virtio', bridge: 'vmbr0', mac: '0a:1b:2c:3d:4e:5b'}\

Dependencies
------------


Example Playbook
----------------

    - hosts: proxmox
      gather_facts: false
      roles:
         - roles/manage_vms


License
-------



Author Information
------------------

Patrick Powell
