Role Name
=========

Get Elasticsearch cluster status with call to {{esmaster}} cluster health as defined in your ansible tree.

Requirements
------------

Role Variables
--------------

esmaster:  master node

Dependencies
------------


Example Playbook
----------------

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