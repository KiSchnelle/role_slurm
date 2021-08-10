#!/bin/sh
# Make sure to have all nodes time synchronized by for example using ntp !!

# Define ansible credentials.
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

# Create folder where role will be saved
mkdir -p /var/log/ansible/roles

# Install dependencies
ansible-galaxy collection install ansible.posix
ansible-galaxy collection install community.mysql
ansible-galaxy collection install community.general

# clone github repo
cd /var/log/ansible/roles
git clone https://github.com/KiSchnelle/role_slurm.git

# override default variables file
cat << EOF > /var/log/ansible/roles/role_slurm/defaults/main.yml
# role_slurm variables
slurm_version: 20.11.8 # tested for 20.11.8
#
# add numbers to list for type of installation, controller can be installed multiple times, first controller can also be database
# 1=compute, 2=database, 3=controller, 4=first controller
install_code_list: [1,2,3,4]
# when installing on ubuntu this can be set to true to use apt for isntallation
package_install: false
#
# following needed if installlation is not for primary controller
# primary_controller_hostname: $PRIMARY_CONTROLLER_HOSTNAME
# primary_controller_ip: $PRIMARY_CONTROLLER_IP
# primary_ansible_user: $ANSIBLE_USER
# primary_ansible_pw: $ANSIBLE_USER_PASSWORD
#
# following needed if installation is for primary controller
cluster_name: $CLUSTER_NAME
#
# following needed if installation is not for database
# database_hostname: $DATABASE_HOSTNAME
#
# following needed if installation is for database
mariadb_root_password: $MARIADB_ROOT_PASSWORD
mariadb_slurm_password: $MARIADB_SLURM_PASSWORD
#
#
# custom_slurm_conf_path:
EOF

cd role_slurm
mkdir install
cd /var/log/ansible
cp /var/log/ansible/roles/role_slurm/run.yml .
ansible-playbook run.yml --user=$ANSIBLE_USER --extra-vars "ansible_sudo_pass=$ANSIBLE_USER_PASSWORD" >> role_slurm_log.txt

rm /var/log/ansible/roles/role_slurm/defaults/main.yml

cd /var/log/ansible

