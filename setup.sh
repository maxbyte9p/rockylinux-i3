#!/bin/bash

runby="root"
iam=`/usr/bin/id -un`
if [ $iam != "$runby" ]
then
    echo "$PGM : program must be run by user \"$runby\""
    exit
fi

function check_installed() {
	dnf list installed | grep -oP "^$1(\.\w+)" &> /dev/null
	return $?
}

function check_enabled() {
	dnf repolist | grep "^$1" &> /dev/null
	return $?
}

function echo_info() {
	echo "* $@"
}

echo_info "Checking if epel-release is installed..."
if ! check_installed epel-release; then
	echo_info "epel-release not installed. Installing now."
	dnf install epel-release -y
fi

echo_info "Checking if ansible is installed..."
if ! check_installed ansible; then
	echo_info "ansible not installed. Installing now."
	dnf install ansible -y
fi

echo_info "Checking if CRB repository is enabled..."
if ! check_enabled crb; then 
	echo_info "CRB not enabled. Enabling now."
	dnf config-manager --set-enabled crb
fi

echo_info "Running ansible playbook..."
ansible-playbook playbook.yml
