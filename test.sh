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
adduser --home /var/lib/ansible --gecos "" --disabled-password $ANSIBLE_USER
echo $ANSIBLE_USER:$ANSIBLE_USER_PASSWORD | chpasswd
usermod -aG sudo $ANSIBLE_USER

# for CentOS uncomment this
# yum update --yes
# yum install epel-release --yes
# yum install ansible --yes
# yum install git --yes
# adduser --home /var/lib/ansible $ANSIBLE_USER
# echo $ANSIBLE_USER:$ANSIBLE_USER_PASSWORD | chpasswd
# usermod -aG wheel $ANSIBLE_USER


# create folder for stuff we need
mkdir -p /var/log/ansible/roles


ansible-galaxy collection install ansible.posix
ansible-galaxy collection install community.mysql
ansible-galaxy collection install community.general
cd /var/log/ansible/roles
git clone https://github.com/KiSchnelle/role_slurm.git
cat << EOF >> /var/log/ansible/roles/role_slurm/defaults/main.yml
# slurm variables, controller can be installed multiple times, first controller can also be database
# 1=compute, 2=database, 3=controller, 4=first controller
install_code_list: [1,2,3,4]
#
# following neeeded if installlation is not for controller
slurm_controller_hostname: $slurm_controller_hostname
slurm_controller_ip: $slurm_controller_ip
#
# following needed if installation is not for database
slurm_database_hostname: $slurm_controller_hostname
#
# following needed if installation is for database
mariadb_root_password: $mariadb_root_password
mariadb_slurm_password: $mariadb_slurm_password
#
cluster_name: $cluster_name
slurm_version: 20.11.8 # tested for 20.11.8
#
EOF


cd role_slurm
mkdir install
cd /var/log/ansible
cp /var/log/ansible/roles/role_slurm/run.yml .
ansible-playbook run.yml --user=$ANSIBLE_USER --extra-vars "ansible_sudo_pass=$ANSIBLE_USER_PASSWORD ansible_ssh_pass=$ANSIBLE_USER_PASSWORD host_key_checking=False" >> log.txt



cd /var/log/ansible

