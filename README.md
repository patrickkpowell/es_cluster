Deploy an Elasticsearch cluster
=========

Set of roles to deploy an Elasticsearch cluster on Proxmox.

### Status
~~Elasticsearch nodes work.  Optimization needed.~~

~~Working on kibana installation role.  Currently getting this error.~~

~~```~~
~~[ERROR][elasticsearch-service] Unable to retrieve version information from Elasticsearch nodes. self signed certificate in certificate chain~~
~~```~~

~~Generate CA & certificates.~~


TODO:

Set Firewall Rules

Set selinux rules

~~Jinja2 template for elasticsearch.yml~~

Jinja2 template for JVM Options

Clean up generated certificates after install so they don't interfiere with subsequent playbook runs

Requirements
------------
To deploy from a Proxmox server you will need the community.general.proxmox_* ansible modules

Need to use ansible vault to generate values for variables.  See defaults/main.yml for example.  It is reccomended that these be overridden in group_vars/all.
DHCP reservations and DNS enreies should be made for the mac values listed in the vm's dictionary.

These roles are written for CentOS 8 and would need to be extended to support other OS's and package managers.

The only role that should require anything Proxmox is the manage_vms role.  Elasticsearch deployment roles should be compatible ith other virtual or physical infrastructure.

Network infrastructure should be configured with DHCP reservations and DNS enries for all systems defines in the "vms" defined below.  

Usage
--------------
Files that require configuration:

group_vars/all.yml
  
- Contains variables for all roles in the tree.

group_vars/vault.yml
- Provides encrypted area for sensitive information.

hosts.yml
- Ansible inventory file.

Configuration
--------------
This Ansible tree is split up into two major areas:
1. Deploying VM's within an infrastructure (Currently ProxMox only)
2. Provisioning and installing Elastic components to those VM's

For the most part, configurations specific to deploying VM's is in group_vars files where the deployment of Elastic components and dependencies is in the host inventory file with some exception.  Anything that should be private such as tokens and passwords should be placed in the vault.
## group_vars/all.yml

Although encrypting strings into the group_vars/all.yml file will work it is reccomended to create a group_vars/vault.yml file to keep sensitive data.  Variable will work in either place although it is much more manageable to create and edit a single encrypted file than to encrypt all of the string values separately.  It also reduces the risk of accidentally encrypting variables with different passwords causing failure to read the variables into the role.

To create the vault file:
```
ansible-vault create group_vars/vault.yml
```
You will be prompted to set a vault password.

To edit the file:
```
ansible-vault edit group_vars/vault.yml
```
You will be prompted for the vault password set in the previous step.  You can also create a file with the password and reference it on the command line with the _--vault-password-file=_ command line option.  This is useful for automation although the password exists in clear text in this case.

```
  api_user:
    Proxmox API username - Recommend putting this in group_vars/vault.yml.  To generate for group_vars all do:
      # ansible-vault encrypt_string '<api password>' --name 'api_user'
  api_pass:
    Proxmox API password - Recommend putting this in group_vars/vault.yml.  To generate for group_vars all do: 
      # ansible-vault encrypt_string '<api password>' --name 'api_pass'
  api_port:
    Proxmox API port - Recommend putting this in group_vars/vault.yml.  To generate for group_vars all do:
      # ansible-vault encrypt_string '<port number>' --name 'api_port'
  vm_node:
    Proxmox host to contact - Recommend putting this in group_vars/vault.yml.  To generate for group_vars all do:
      # ansible-vault encrypt_string '<node name>' --name 'vm_node'
  api_host: 
    Proxmox API host - Recommend putting this in group_vars/vault.yml.  To generate for group_vars all do:
      # ansible-vault encrypt_string '<host name>' --name 'api_host'
  TLS_Pass:
    PKCS12 certificate password - Recommend putting this in group_vars/vault.yml.  To generate for group_vars all do:
      # ansible-vault encrypt_string '<password>' --name 'TLS_Pass'
  vm_template: 
    'Proxmox template or VM to deploy from' These role were built using CentOS and would have to be extended to use another package manager
  vm_cores: 
    'Number of cores on VM'
  vm_memory:
    'Memory allocated to VM'
  vm_disk_size:
    'Disk size of VM'
  template_id: Id of ProxMox VM
  vms:
    - {name: 'es01.domain.com', interface: 'net0', nic: 'virtio', bridge: 'vmbr0', mac: '00:11:22:33:44:55', esnode: es01, type: 'es'}
    - {name: 'es02.domain.com', interface: 'net0', nic: 'virtio', bridge: 'vmbr0', mac: '00:11:22:33:44:56', esnode: es02, type: 'es'}
    - {name: 'es03.domain.com', interface: 'net0', nic: 'virtio', bridge: 'vmbr0', mac: '00:11:22:33:44:57', esnode: es03, type: 'es'} 
    - {name: 'kib01.domain.com', interface: 'net0', nic: 'virtio', bridge: 'vmbr0', mac: '00:11:22:33:44:58', esnode: kib01, type: 'kib'}
    - {name: 'fl01.domain.com', interface: 'net0', nic: 'virtio', bridge: 'vmbr0', mac: '00:11:22:33:44:60', esnode: flt01, type: 'fleet'}
```
_mac address in vm's is useful when deploying into an environment with DHCP reservations_

_type is used to determine which template to deploy.  In the above case 'type=es' will deploy a template with a dedicated data volume, 'type=kib' will deploy a minimal vm and 'type=ml' will deploy an instance with a GPU attached._

Currently unsure of how ansible sets precidence on these variables so ensure that you don't have the same variable set in both group_vars/all.yml and group_vars/vault.yml.
### group_vars/vault.yml
```
api_user: "Proxmox username"
api_pass: "Proxmox password"
api_port: "Proxmox API port"
vm_node: "Proxmox node server"
api_host: "Proxmox API server"
TLS_Pass: "Password for Elasticsearch certificate files for use with elasticsearch-certutil"
admin_users:
  - { username: 'user', password: 'pass', roles: [ 'superuser' ], full_name: 'Full Name', email: 'first.last@elastic.co' }
```
## hosts.yml

I am still working on the best host groupings but the highlights are this:

1. The 'all' group includes infrastructure (Proxmox) hosts so it cannot be used in alot of cases when deploying elastic components.
2. 'es_nodes' is all elastic component nodes and where all global variables are set.
3. Role groups such as kibana_nodes, data_nodes, etc. are created motly for limiting operations withing this tree specific to those types of nodes.
4. artifact_repo_base_url should be able to be used in isolated on-prem environments.  This should either be pointed at a repository on-prem or can be self hosted from the system running ansible using the 'file:///var/ansible/...' syntax.

```---
all:
  hosts:
    localhost:
      localhost ansible_connection: 'local'
      ansible_host: 127.0.0.1
    pve.domain.com:
      ansible_user: 'user@pam'
    es01.domain.com:
      ansible_host: IP
    es02.domain.com:
      ansible_host: IP
    es03.domain.com:
      ansible_host: IP
    es04.domain.com:
      ansible_host: IP
    kib01.domain.com:
      ansible_host: IP
    fl01.domain.com:
      ansible_host: IP
proxmox:
  hosts:
    pve.domain.com:
cert_node:
  hosts:
    es02.domain.com:
data_nodes:
  vars:
    roles: ['data', 'ingest', 'remote_cluster_client']
    svc_group: 'elasticsearch'
  hosts:
    es02.domain.com:
    es03.domain.com:
master_nodes:
  vars:
    roles: ['master']
    svc_group: 'elasticsearch'
  hosts:
    es01.domain.com:
ml_nodes:
  vars:
    roles: ['ml', 'remote_cluster_client']
    svc_group: 'elasticsearch'
  hosts:
    es04.domain.com:
seed_nodes:
  children:
    data_nodes:
    master_nodes:
    ml_nodes:
elastic_nodes:
  vars:
    artifact_repo_base_url: "http://artifacts.domain.com/elasticsearch"
    es_version: "8.10.2"
    kib_url: "https://kib01.domain.com:5601"
    es_cert_dir: "/etc/elasticsearch/certs"
    es_installer_url: "{{ artifact_repo_base_url }}/elasticsearch-{{ es_version }}-x86_64.rpm"
    es_installer_sha_url: "{{ artifact_repo_base_url }}/elasticsearch-{{ es_version }}-x86_64.rpm.sha512"
    kib_installer_url: "{{ artifact_repo_base_url }}/kibana-{{ es_version }}-x86_64.rpm"
    kib_installer_sha_url: "{{ artifact_repo_base_url }}/kibana-{{ es_version }}-x86_64.rpm.sha512"
    elastic_agent_installer_url: "{{ artifact_repo_base_url }}/elastic-agent-{{ es_version }}-x86_64.rpm"
    elastic_agent_installer_sha_url: "{{ artifact_repo_base_url }}/elastic-agent-{{ es_version }}-x86_64.rpm.sha512"
    metricbeat_installer_url: "{{ artifact_repo_base_url }}/metricbeat-{{ es_version }}-x86_64.rpm"
    metricbeat_installer_sha_url: "{{ artifact_repo_base_url }}/metricbeat-{{ es_version }}-x86_64.rpm.sha512"
    filebeat_installer_url: "{{ artifact_repo_base_url }}/filebeat-{{ es_version }}-x86_64.rpm"
    filebeat_installer_sha_url: "{{ artifact_repo_base_url }}/filebeat-{{ es_version }}-x86_64.rpm.sha512"
    fleet_policy_name: "fleet-policy-name"
    packages:
      - "qemu-guest-agent"
      - "yum-utils"
      - "net-tools"
      - "mlocate"
      - "wget"
      - "zip"
      - "unzip"
      - "jq"
      - bash-completion
      - bind-utils
      - "tar"
    kib_user: "kibana"
    cluster_name: "my-cluster"
    tmp_dir: "/tmp/" # STIG's systems typically don't like this location so it can be changed.
    elastic_home: "/usr/share/elasticsearch"
    elasticsearch_certutil_bin: "{{ elastic_home }}/bin/elasticsearch-certutil"
    kibana_home: "/usr/share/kibana"
    es_data_dir: "/var/lib/elasticsearch"
    es_log_dir: "/var/log/elasticsearch"
    es_config_dir: "/etc/elasticsearch"
    elasticsearch_certutil_ca_path: "{{ es_config_dir }}/certs/ca"
    kib_config_dir: "/etc/kibana"
    es_config_file: "elasticsearch.yml"
    kib_config_file: "kibana.yml"
    es_service_name: "elasticsearch"
    kib_service_name: "kibana"
  children:
    data_nodes:
    master_nodes:
    ml_nodes:
    fleet_nodes:
    kibana_nodes:
kibana_nodes:
  vars:
    svc_group: 'kibana'
  hosts:
    kib01.domain.com:
all_es_nodes:
  children:
    elastic_nodes:
    kibana_nodes:
    ml_nodes:
    data_nodes:
    master_nodes:
fleet_nodes:
  hosts:
    fl01.domain.com:
  vars:
    svc_group: 'root'
elastic_agents:
  children:
    fleet_nodes:
macos_nodes:
  hosts:
    IP
      ansible_python_interpreter: /usr/bin/python3
    IP
      ansible_python_interpreter: /usr/bin/python3
windows_nodes:
  hosts:
agents:
  children:
    all_es_nodes:
    fleet_nodes:
templates:
  hosts:
    estemplate.domain.com: null
    kibtemplate.domain.com: null
    mltemplate.domain.com: null```
```
----------------
### To run the playbook:
### Create

Run from within the es_cluster directory
```
./create_es.sh
or
ansible-playbook -i hosts.yml playbooks/deploy_es_cluster.yml --vault-password-file=./.pass --tags create
```

### Destroy
```
./destroy_es.sh
or
ansible-playbook -i hosts.yml playbooks/deploy_es_cluster.yml --vault-password-file=./.pass --tags destroy
```

### Playbook - playbooks/deploy_es_cluster.yml
This orchestrates the order and dependencies of operations

```
---

# Remove any certs that were fetched to the local system from any previous runs.
# This ensures that old certificates do not get pushed on subsequent runs.
# Since the creation of certificates and ca are idempotent, existing certs from 
# previous runs will be preserved and re-fetched.

- name: Cleanup before we start
  hosts: cert_node
  gather_facts: false
  roles:
    - roles/cleanup

# Only concern yourself with this if you happen to be running Proxmox
# Deploys VM's from templates

- name: Create a Proxmox VM's
  hosts: proxmox
  gather_facts: true
  roles:
    - roles/manage_vms

# Does some baseline OS configuration such as dependent yum package installs
# selinux configuration, firewall configuration, etc.

- name: Provision Proxmox VM's
  hosts: 
    - data_nodes
    - master_nodes
    - ml_nodes
    - kibana_nodes
    - fleet_nodes
  become: yes
  become_method: sudo
  become_user: root
  gather_facts: false
  roles:
    - roles/provision_vms

# Download and install Elasticsearch to initial seed_nodes.
# Push jinja2 templated yml files.
# Does not enable or run the service as certificates have not been created or pushed.
# Installation is necessary to get binaries required to generate certs.

- name: Install Elasticsearch
  hosts: 
    - seed_nodes
  become: yes
  become_method: sudo
  become_user: root
  gather_facts: false
  roles:
    - roles/install_elastic

# Pick one host (cert_node) to generate ca and certificates.
# Push generated certificates to initial cluster.

- name: Create and distribute Certificates to seed nodes
  hosts:
    - seed_nodes
  become: yes
  become_method: sudo
  become_user: root
  gather_facts: false
  roles:
    - roles/manage_certs

# Start the cluster.
# We now have a cluster to run commands against for the next steps.

- name: Start Elasticsearch Seed Nodes
  hosts: 
    - seed_nodes
  become: yes
  become_method: sudo
  become_user: root
  gather_facts: false
  roles:
    - roles/start_stop_elastic

# Prints cluster status and elastic password

- name: Get Cluster Status
  hosts: 
    - master_nodes
  become: yes
  become_method: sudo
  become_user: root
  gather_facts: false
  roles:
    - roles/get_cluster_status

# Create kibana account in cluster and print password.
# Creates admin user(s) as defined in 'admin_users' variable in vault.yml

- name: Create Users
  hosts:
    - cert_node
  become: yes
  become_method: sudo
  become_user: root
  gather_facts: false
  roles:
    - roles/manage_access

# Install kibana on 'kibana_nodes'.
# Do not enable or start the service.
# This creates the local kibana service account so we can push 
# certificates and set permissions correclty.

- name: Install Kibana
  hosts: 
    - kibana_nodes
  become: yes
  become_method: sudo
  become_user: root
  gather_facts: false
  roles:
    - roles/install_kibana

# Push all elastic agents

- name: Install elastic_agent
  hosts: 
    - elastic_nodes
  become: yes
  become_method: sudo
  become_user: root
  gather_facts: false
  roles:
    - roles/install_agents

# Push certificates to remaining systems.

- name: Create and distribute Certificates to all nodes
  hosts:
    - elastic_nodes
  become: yes
  become_method: sudo
  become_user: root
  gather_facts: false
  roles:
    - roles/manage_certs

- name: Cleanup when we're done
  hosts: cert_node
  gather_facts: false
  roles:
    - roles/cleanup

```
License
-------


Author Information
------------------

Patrick Powell