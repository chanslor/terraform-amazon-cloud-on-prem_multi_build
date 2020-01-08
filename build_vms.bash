#!/bin/bash

if [ "$#" -eq 0 ]; then
	echo
	echo "This program requires at least one arg, the name of the vm to create."
	echo
	echo "$0 aws3"
	echo "or"
	echo "$0 aws1 aws2 aws3 aws4 aws5 aws6"
	echo
	exit 1
fi

spinner()
{
    local pid=$1
    local delay=0.75
    local spinstr='|/-\'
    while [ "$(ps a | awk '{print $1}' | grep $pid)" ]; do
        local temp=${spinstr#?}
        printf " [%c]  " "$spinstr"
        local spinstr=$temp${spinstr%"$temp"}
        sleep $delay
        printf "\b\b\b\b\b\b"
    done
    printf "    \b\b\b\b"
}


for i in $@
do
	seq -s'#' 0 $(tput cols) | tr -d '[:digit:]'
	echo -e "\\033[1;42m      $i      \\033[0;39m"

	pushd $PWD
	#create working subdir
	if [ -d $i ] ; then 
		cd $i
		rm -rf .terraform terraform.tfstate*
	else
		mkdir $i
		cd $i
	fi

	#copy files into place
	cp ../variables.tf .
	cp ../kvm.tf .
	cp ../network_config.cfg .
	cp ../cloud_init.cfg .

	terraform init -var "virtname=$i"
	terraform plan -var "virtname=$i"
	terraform apply -var "virtname=$i" -auto-approve

	seq -s'#' 0 $(tput cols) | tr -d '[:digit:]'
	VIRSH_ID=$(sudo virsh list --all  | /bin/grep $i | awk ' { print $1 } ')
	echo "Build for ------ $i ------- " | tee -a build.log
	echo "Waiting on ip..."
	sleep 30 > /dev/null 2>&1 &
	spinner $!
	sudo virsh domifaddr $VIRSH_ID | tee -a build.log
	sleep 5
	seq -s'#' 0 $(tput cols) | tr -d '[:digit:]'

	popd
done
