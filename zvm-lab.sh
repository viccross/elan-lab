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
	echo "  up        Start the lab or individual machine"
	echo "  halt      Stop the lab or individual machine"
	echo "  destroy   Stop the lab (or individual machine) and target"
	echo "            it/them for rebuild"
	echo "  provision Run the provisioning"
	echo "  status    Show the state of the lab"
	echo
	echo "TARGET is an optional machine name for the action"
}

startall() {
	for num in $(seq 1 3); do
		chvm -a lxelan0${num}
		sleep 2
	done
}

stopall() {
	for num in $(seq 1 3); do
		chvm -d lxelan0${num}
		sleep 1
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
	ansible-playbook -i ansible/inventory-zvm --limit $1 ansible/build-an-elan.yml
	echo "provisioned" > .$1
}

provall() {
	ansible-playbook -i ansible/inventory-zvm ansible/build-an-elan.yml
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
			if [[ "$(cat .lxelan* | uniq | wc -l)" == "1" && "$(cat .lxelan01)" == "destroyed" ]]; then
				provall
				setall 200
			else
				for num in $(seq 1 3); do
					if [[ "$(cat .lxelan0${num})" == "destroyed" ]]; then
						provone lxelan0${num}
						chvmipl -i 200 lxelan0${num}
					else
						echo "lxelan0${num} already provisioned"
					fi
				done
			fi
		else
			chvm -a $2
			chvmipl -i 200 $2
			if [[ "$(cat .$2)" == "destroyed" ]]; then
				provone $2
			fi
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
			echo "Doing cleanup of defined guests"
			ansible-playbook -i ansible/inventory-zvm ansible/cleanup-guests.yml
			stopall
			setall CMS
			for num in $(seq 1 3); do
				echo "destroyed" > .lxelan0${num}
				while lsvm -s lxelan0${num} >/dev/null; do sleep 1; done
				echo "lxelan0${num} destroyed."
			done
		else
			if [[ $2 == "lxelan01 "]]; then
				echo "Doing cleanup of defined guests"
				ansible-playbook -i ansible/inventory-zvm ansible/cleanup-guests.yml
			fi
			chvm -d $2
			chvmipl -i CMS $2
			echo "destroyed" > .$2
			while lsvm -s $2 >/dev/null; do sleep 1; done
			echo "$2 destroyed."
		fi
	;;
	provision)
		if [[ -z $2 ]]; then
			provall
		else
			provone $2
		fi
	;;
	status)
		echo "ELAN-lab status:"
		for num in $(seq 1 3); do
			updown=$(if lsvm -s lxelan0${num} >/dev/null; then echo "up"; else echo "down"; fi)
			prov=$(cat .lxelan0${num})
			printf "lxelan0%d is %s and %s\n" ${num} ${updown} ${prov}
		done
	;;
	*)
		echo "Not a valid action" 
		usage
		exit 2
	;;
esac

