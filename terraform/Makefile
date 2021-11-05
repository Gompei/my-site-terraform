-include .env

MAKEFILE_DIR:=$(dir $(abspath $(lastword $(MAKEFILE_LIST))))
PARENT_DIR:=$(shell dirname ${MAKEFILE_DIR})

.PHONY: help
help: ## 各makeコマンドの説明を表示します
	@grep -E '^[0-9a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

.PHONY: build
build:
	GOOS=linux GOARCH=amd64 go build -o handler ../example_code/lambda
	zip lambda.zip handler

.PHONY: init
init: ## テラフォームの設定ファイルを含む作業ディレクトリを初期化します
	terraform init -reconfigure -backend-config=.tfbackend

.PHONY: plan
plan: ## テラフォームによる実行計画を参照します
	terraform plan -var-file .tfvars

.PHONY: apply
apply: build ## tf ファイルに記載された情報を元にリソースを作成します
	terraform apply -var-file .tfvars -auto-approve
	aws s3 cp ${PARENT_DIR}/example_code/s3/index.html s3://${S3_BUCKET_NAME}

.PHONY: destroy
destroy: ## tf ファイルに記載された情報を元にリソースを削除します
	aws s3 rm s3://${S3_BUCKET_NAME} --recursive
	terraform destroy -var-file .tfvars -auto-approve

api-test:
	curl https://${API_DOMAIN}/api --header 'x-api-key: ${API_KEY}'