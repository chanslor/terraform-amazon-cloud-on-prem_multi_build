#!/bin/bash


for i in $@
do
	seq -s'#' 0 $(tput cols) | tr -d '[:digit:]'
	echo -e "\\033[1;42m      $i      \\033[0;39m"

	rm -rf .terraform terraform.tfstate*
	terraform init -var "virtname=$i"
	terraform plan -var "virtname=$i"
	terraform apply -var "virtname=$i"
	seq -s'#' 0 $(tput cols) | tr -d '[:digit:]'
	sleep 5
done


exit 0

terraform init
terraform plan
terraform apply -auto-approve
terraform apply -var "virtname=$i"
# terraform destroy -auto-approve

