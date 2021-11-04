init:
	terraform init -reconfigure -backend-config=.tfbackend

plan:
	terraform plan -var-file .tfvars

apply:
	terraform apply -var-file .tfvars -auto-approve

destroy:
	terraform destroy -var-file .tfvars -auto-approve
