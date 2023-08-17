Deploy an Elasticsearch cluster
=========

Set of roles to deploy an Elasticsearch cluster on Proxmox.

Requirements
------------
Need to use ansible vault to generate values for variables.  See defaults/main.yml for example.  It is reccomended that these be overridden in group_vars/all.
DHCP reservations and DNS enreies should be made for the mac values listed in the vm's dictionary.
community.general.proxmox_* modules

Role Variables
--------------
### group_vars/all.yml
#### manage_vms Role

  `api_user: Proxmox API username - Generate this with "ansible-vault encrypt_string '<api password>' --name 'api_pass'"
  api_pass: Proxmox API password - Generate this with "ansible-vault encrypt_string '<api password>' --name 'api_pass'"
  api_port: Proxmox API port - Generate this with "ansible-vault encrypt_string '<port number>' --name 'api_port'"
  vm_node: Proxmox host to contact - Generate this with "ansible-vault encrypt_string '<node name>' --name 'vm_node'"
  api_host: Proxmox API host - Generate this with "ansible-vault encrypt_string '<host name>' --name 'api_host'"
  vm_template: 'Proxmox template or VM to deploy from' These role were built using CentOS and would have to be extended to use another package manager
  vm_cores: Number of cores on VM
  vm_memory: Memory allocated to VM
  vm_disk_size: Disk size of VM
  template_id: Id of ProxMox VM
  vms: # Dict of VM's to deploy
    - {name: 'es01.domain.com', interface: 'net0', nic: 'virtio', bridge: 'vmbr0', mac: '00:11:22:33:44:55'}
    - {name: 'es02.domain.com', interface: 'net0', nic: 'virtio', bridge: 'vmbr0', mac: '00:11:22:33:44:56'}
    - {name: 'es03.domain.com', interface: 'net0', nic: 'virtio', bridge: 'vmbr0', mac: '00:11:22:33:44:57'}`

#### provision_vms Role
  packages:
    - 'qemu-guest-agent'
    - 'yum-utils'
    - 'net-tools'
    - 'mlocate'
    - 'wget'

#### install_elastic Role
  es_installer_url: 'http://artifacts.elastic.co/elasticsearch/elasticsearch-8.9.0-x86_64.rpm' \
  es_installer_sha_url: 'https://artifacts.elastic.co/downloads/elasticsearch/elasticsearch-8.9.0-x86_64.rpm.sha512' 
    
Dependencies
------------

Example Playbook
----------------
## To run the playbook:
### Create
`ansible-playbook -i hosts.yml playbooks/deploy_es_cluster.yml --vault-password-file=./.pass --tags create`

### Destroy
`ansible-playbook -i hosts.yml playbooks/deploy_es_cluster.yml --vault-password-file=./.pass --tags destroy`

### Playbook

  - name: Create a Proxmox VM's
    hosts: proxmox
    gather_facts: true
    roles:
      - roles/manage_vms
      
  - name: Provision Proxmox VM's
    hosts: 
      - esnodes
      - esmaster
    become: yes
    become_method: sudo
    become_user: root
    gather_facts: false
    roles:
      - roles/provision_vms
      - roles/install_elastic
  
  - name: Get Cluster Status
    hosts: 
      - esmaster
    become: yes
    become_method: sudo
    become_user: root
    gather_facts: false
    roles:
      - roles/get_cluster_status

License
-------


Author Information
------------------

Patrick Powell