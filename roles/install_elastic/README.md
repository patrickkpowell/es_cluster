Role Name
=========

Downloads Elasticsearch installer and hash.  Validates installer befor installing package. Currently disables firewalld.  Modifies /etc/elasticsearch/elasticsearch.yml and /etc/elasticsearch/jvm.options files (should template these) to create cluster.  Enables and starts service.

Requirements
------------


Role Variables
--------------

es_installer_url: 'http://domain.com/elasticsearch-8.9.0-x86_64.rpm'
es_installer_sha_url: 'https://artifacts.elastic.co/downloads/elasticsearch/elasticsearch-8.9.0-x86_64.rpm.sha512'
tmp_dir: '<artifact download directory>'

Dependencies
------------

A list of other roles hosted on Galaxy should go here, plus any details in regards to parameters that may need to be set for other roles, or variables that are used from other roles.

Example Playbook
----------------

Including an example of how to use your role (for instance, with variables passed in as parameters) is always nice for users too:

    - name: Deploy Proxmox VM's
      hosts: esnodes,esmaster
      gather_facts: false
      roles:
      - roles/install_elastic

License
-------


Author Information
------------------

Patrick Powell