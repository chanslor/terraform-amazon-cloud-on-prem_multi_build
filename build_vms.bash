#!/bin/bash


for i in $@
do
	seq -s'#' 0 $(tput cols) | tr -d '[:digit:]'
	echo -e "\\033[1;42m      $i      \\033[0;39m"

	rm -rf .terraform terraform.tfstate*
	terraform init -var "virtname=$i"
	terraform plan -var "virtname=$i"
	terraform apply -var "virtname=$i" -auto-approve

	echo -e "\\033[1;41m "
	seq -s'#' 0 $(tput cols) | tr -d '[:digit:]'
	VIRSH_ID=$(sudo virsh list --all  | /bin/grep $i | awk ' { print $1 } ')
	echo "Build for ------ $i ------- " | tee -a build.log
	sudo virsh domifaddr $VIRSH_ID | tee -a build.log
	sleep 30
	seq -s'#' 0 $(tput cols) | tr -d '[:digit:]'
	echo -e " \\033[0;39m"
done


exit 0

terraform init
terraform plan
terraform apply -auto-approve
terraform apply -var "virtname=$i"
# terraform destroy -auto-approve

