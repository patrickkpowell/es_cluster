Deploy an Elasticsearch cluster
=========

Set of roles to deploy an Elasticsearch cluster on Proxmox

Requirements
------------


Role Variables
--------------

  api_user: Generate this with "ansible-vault encrypt_string '<api password>' --name 'api_pass'"\
  api_pass: Generate this with "ansible-vault encrypt_string '<api password>' --name 'api_pass'"\
  api_port: Generate this with "ansible-vault encrypt_string '<port number>' --name 'api_port'"\
  vm_node: Generate this with "ansible-vault encrypt_string '<node name>' --name 'vm_node'"\
  api_host: Generate this with "ansible-vault encrypt_string '<host name>' --name 'api_host'"\
  vm_template: 'Template name' This role was built using CentOS and would have to be extended to use another package manager\
  vm_cores: '1'\
  vm_memory: '4096'\
  vm_disk_size: '20G'\
  template_id: '1002'\
  vms: # VM's to deploy\
    - {name: 'es01.domain.com', interface: 'net0', nic: 'virtio', bridge: 'vmbr0', mac: '00:11:22:33:44:55'}\
    - {name: 'es02.domain.com', interface: 'net0', nic: 'virtio', bridge: 'vmbr0', mac: '00:11:22:33:44:56'}\
    - {name: 'es03.domain.com', interface: 'net0', nic: 'virtio', bridge: 'vmbr0', mac: '00:11:22:33:44:57'}\
  es_installer_url: 'http://artifacts.elastic.co/elasticsearch/elasticsearch-8.9.0-x86_64.rpm' \
  es_installer_sha_url: 'https://artifacts.elastic.co/downloads/elasticsearch/elasticsearch-8.9.0-x86_64.rpm.sha512' \

Dependencies
------------

Example Playbook
----------------

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