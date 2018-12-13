#!/bin/bash
set -e

export USER=root

echo "[Packer validation]"

for temp in `ls packer/*.json`
do
	packer validate -var-file=packer/variables.json.example $temp
done

touch ~/.ssh/appuser.pub
touch ~/.ssh/appuser
cd terraform

declare -a env=(stage prod modules/*)
for dir in "${env[@]}"
do
	cd $dir

	if [[ $dir != modules/* ]]; then
		terraform init > /dev/null
		mv terraform.tfvars.example terraform.tfvars
		terraform validate
		echo "[Terraform validation for $dir successful!]"
	fi
	echo "[tflint validation for $dir]"
	tflint
	cd - > /dev/null
done

echo "[ansible-lint validation]"

cd ../ansible/playbooks
for f in `ls`
do
	echo $f
	ansible-lint $f
done

echo "[ansible-lint validation successful!]"
exit 0
