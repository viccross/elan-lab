#!/bin/bash
#
# zvm-lab.sh
# Operate the lab on z/VM
# Simulate a couple of the actions offered by Vagrant
# - up
# - halt
# - destroy
# - provision

usage() {
	echo "$0 - Operate the ELAN lab (z/VM version)"
	echo "usage: $0 ACTION [TARGET]"
	echo 
	echo "ACTIONS"
	echo "  up       Start the lab or individual machine"
	echo "  halt     Stop the lab or individual machine"
	echo "  destroy  Stop the lab (or individual machine) and target"
	echo "           it/them for rebuild"
	echo "  provision Run the provisioning"
	echo
	echo "TARGET is an optional machine name for the action"
}

startall() {
	for num in $(seq 1 3); do
		chvm -a lxelan0${num}
		sleep 3
	done
}

stopall() {
	for num in $(seq 1 3); do
		chvm -d lxelan0${num}
		sleep 3
	done
}

setall() {
	for num in $(seq 1 3); do
		curi=$(lsvmipl -d lxelan0${num})
		if [[ "${curi}" != "$1" ]]; then
			chvmipl -i $1 lxelan0${num}
			sleep 1
		fi
	done
}

provone() {
	ansible-playbook -v -i ansible/inventory-zvm --limit $1 ansible/build-an-elan.yml
	echo "provisioned" > .$1
}

provall() {
	ansible-playbook -v -i ansible/inventory-zvm ansible/build-an-elan.yml
	for num in $(seq 1 3); do
		echo "provisioned" > .lxelan0${num}
	done
}

if [[ -z $1 ]]; then
	echo "No option specified!"
	usage
	exit 1
fi

case $1 in
	up)
		if [[ -z $2 ]]; then
			startall
			setall 200
		else
			chvm -a $2
			chvmipl -i 200 $2
		fi
	;;
	halt)
		if [[ -z $2 ]]; then
			stopall
		else
			chvm -d $2
		fi
	;;
	destroy)
		if [[ -z $2 ]]; then
			stopall
			setall CMS
			for num in $(seq 1 3); do
				echo "destroyed" > .lxelan0${num}
			done
		else
			chvm -d $2
			chvmipl -i CMS $2
			echo "destroyed" > .$2
		fi
	;;
	provision)
		if [[ -z $2 ]]; then
			provall
		else
			provone $2
		fi
	;;
	*)
		echo "Not a valid action" 
		usage
		exit 2
	;;
esac

