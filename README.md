Deploy an Elasticsearch cluster
=========

Set of roles to deploy an Elasticsearch cluster on Proxmox.

### Status
Elasticsearch nodes work.  Optimization needed.

Working on kibana installation role.  Currently getting this error.

```
[ERROR][elasticsearch-service] Unable to retrieve version information from Elasticsearch nodes. self signed certificate in certificate chain
```

Possibly an openssl role to generate certificates from the same CA and ditribute via ansible.

TODO:

Set Firewall Rules

Set selinux rules

~~Jinja2 template for elasticsearch.yml~~

Requirements
------------
To deploy from a Proxmox server you will need the community.general.proxmox_* ansible modules

Need to use ansible vault to generate values for variables.  See defaults/main.yml for example.  It is reccomended that these be overridden in group_vars/all.
DHCP reservations and DNS enreies should be made for the mac values listed in the vm's dictionary.

These roles are written for CentOS 8 and would need to be extended to support other OS's and package managers.

The only role that should require anything Proxmox is the manage_vms role.  Elasticsearch deployment roles should be compatible ith other virtual or physical infrastructure.

Network infrastructure should be configured with DHCP reservations and DNS enries for all systems defines in the "vms" defined below.  

Role Variables
--------------
## group_vars/all.yml

Reccomend to override variables with group_vars although this can be taylored to your needs.

### roles/manage_vms

```
  api_user:
    Proxmox API username - Generate this with "ansible-vault encrypt_string '<api password>' --name
  api_pass:
    Proxmox API password - Generate this with "ansible-vault encrypt_string '<api password>' --name 'api_pass'"
  api_port:
    Proxmox API port - Generate this with "ansible-vault encrypt_string '<port number>' --name 'api_port'"
  vm_node:
    Proxmox host to contact - Generate this with "ansible-vault encrypt_string '<node name>' --name 'vm_node'"
  api_host: 
    Proxmox API host - Generate this with "ansible-vault encrypt_string '<host name>' --name 'api_host'"
  vm_template: 
    'Proxmox template or VM to deploy from' These role were built using CentOS and would have to be extended to use another package manager
  vm_cores: 
    'Number of cores on VM'
  vm_memory:
    'Memory allocated to VM'
  vm_disk_size:
    'Disk size of VM'
  template_id: Id of ProxMox VM
  vms: # Dict of VM's to deploy
    - {name: 'es01.domain.com', interface: 'net0', nic: 'virtio', bridge: 'vmbr0', mac: '00:11:22:33:44:55'}
    - {name: 'es02.domain.com', interface: 'net0', nic: 'virtio', bridge: 'vmbr0', mac: '00:11:22:33:44:56'}
    - {name: 'es03.domain.com', interface: 'net0', nic: 'virtio', bridge: 'vmbr0', mac: '00:11:22:33:44:57'}
  kib_user: "kibana"
  cluster_name: "cluster_name"
  tmp_dir: "temp/directory/for/roles" 
```

### roles/provision_vms
  ```
  packages:
    - 'qemu-guest-agent'
    - 'yum-utils'
    - 'net-tools'
    - 'mlocate'
    - 'wget'
```

### roles/install_elastic
```
  es_installer_url: 'http://artifacts.elastic.co/elasticsearch/elasticsearch-8.9.0-x86_64.rpm' \
  es_installer_sha_url: 'https://artifacts.elastic.co/downloads/elasticsearch/elasticsearch-8.9.0-x86_64.rpm.sha512' 
```

Dependencies
------------

Example Playbook
----------------
### To run the playbook:
### Create

Run from within the es_cluster directory

```
ansible-playbook -i hosts.yml playbooks/deploy_es_cluster.yml --vault-password-file=./.pass --tags create
```

### Destroy
```
ansible-playbook -i hosts.yml playbooks/deploy_es_cluster.yml --vault-password-file=./.pass --tags destroy
```

### Playbook - playbooks/deploy_es_cluster.yml
```
  - name: Create a Proxmox VM's
    hosts: proxmox
    gather_facts: true
    roles:
      - roles/manage_vms
      
  - name: Provision OS
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
```
License
-------


Author Information
------------------

Patrick Powell