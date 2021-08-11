Ansible Role for Installing Slurm on CentOS 7,8 and Ubuntu 20
=========

This role is can be used to install Slurm.
It was developed in intention to be used inside a bash script in combination with MAAS(Metal as a Service) when deploying a server, but can also be run apart from that.


Requirements
------------

Make sure to have all servers using a form of time synchronizaion like ntp. When using MAAS this is enabled by default and can be configured in the settings.

It was intedend to have a common ansible user/password on all servers. When installing not as controller the installation will need to access the controller server via ssh conntionc with password authentication. Key authentication is not supported yet, since i havnt found a clean way for using it when deploying fresh servers.

Role Variables
--------------

Variables can be found in the defaults/main.yml file and vars/main.yml. Variables in vars take priority over the ones in defaults.
Using MAAS you could also copy a file from f.e. a nfs share before or use cat to override the cloned filed.

Dependencies
------------

This role depends on the ansible.posix, community.mysql and community.general collections.
To install them type for example:
```
ansible-galaxy collection install ansible.posix
```

Example Playbook
----------------

Using MAAS:
When deploying a machine add a bash script like the given example_script.sh as Cloud-init user-data. Which will basically clone the github repo, add custom config if wanted and run the role as if you would run it.


To run it type for example:
```
ansible-playbook run.yml --user=$ANSIBLE_USER --extra-vars "ansible_sudo_pass=$ANSIBLE_USER_PASSWORD" >> role_slurm_log.txt
```
or inside a playbook:
```
- hosts: localhost
  become: True
  roles:
    - role_slurm
```

License
-------

Apache License 2.0

Author Information
------------------

This role was created in 2021 by Kilian Schnelle, part of the Department of Structure Biology at the University of Osnabrueck.
