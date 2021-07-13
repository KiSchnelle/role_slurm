#!/bin/sh
# Make sure to have all nodes time synchronized by for example using ntp !!
ANSIBLE_USER=
ANSIBLE_USER_PASSWORD=

# for Ubuntu uncomment this
apt update
apt upgrade --yes
apt install software-properties-common
add-apt-repository --yes --update ppa:ansible/ansible
apt update
apt install ansible-base --yes
apt install git --yes


# for CentOS uncomment this
# yum update --yes
# yum install epel-release --yes
# yum install ansible --yes
# yum install git --yes


# create ansible user
adduser --home /var/lib/ansible $ANSIBLE_USER
echo $ANSIBLE_USER:$ANSIBLE_USER_PASSWORD | chpasswd
# usermod -aG wheel $ANSIBLE_USER
usermode -aG sudo $ANSIBLE_USER

# create folder for stuff we need
mkdir -p /var/log/ansible/roles


ansible-galaxy collection install ansible.posix
ansible-galaxy collection install community.mysql
cd /var/log/ansible/roles
git clone https://github.com/KiSchnelle/role_slurm.git
cat << EOF >> /var/log/ansible/roles/role_slurm/defaults/main.yml
# slurm variables
slurm_controller: true # if installed as slurm controller
create_munge_key: true # if munge key should be generated, only needed once
munge_key_host: $munge_key_host_ip # host of munge key file
database_server: true # if the node should host the slurm database
mariadb_root_password: $mariadb_root_password # password that will be set as root password for mariadb if not existend
mariadb_slurm_password: $mariadb_slurm_password # password used for mariadb slurm user
database_server_hostname: $database_server_hostname


EOF


cd role_slurm
mkdir install
cd /var/log/ansible
mv /var/log/ansible/roles/role_slurm/run.yml .
ansible-playbook run.yml --user=$ANSIBLE_USER --extra-vars "ansible_sudo_pass=$ANSIBLE_USER_PASSWORD" >> log.txt



cd /var/log/ansible

