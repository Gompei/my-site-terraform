-include .env

MAKEFILE_DIR:=$(dir $(abspath $(lastword $(MAKEFILE_LIST))))
PARENT_DIR:=$(shell dirname ${MAKEFILE_DIR})

.PHONY: help
help: ## 各makeコマンドの説明を表示します
	@grep -E '^[0-9a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

.PHONY: lambda-build
lambda-build: ## goファイルをlambda用にビルドします
	GOOS=linux GOARCH=amd64 go build -o handler ../example_code/lambda
	zip lambda.zip handler

.PHONY: function-build
function-build: ## typescriptファイルをjsファイルにコンパイルします
	npm --prefix ${PARENT_DIR}/cloud_front_function install ${PARENT_DIR}/cloud_front_function
	npm --prefix ${PARENT_DIR}/cloud_front_function run build
	cp -r ${PARENT_DIR}/cloud_front_function/dist ${MAKEFILE_DIR}

.PHONY: apply
apply: lambda-build function-build ## tf ファイルに記載された情報を元にリソースを作成します
	terraform apply -auto-approve

front-upload: ## テスト用のhtmlをs3バケットにアップロードします
	aws s3 cp ${PARENT_DIR}/example_code/s3/index.html s3://${S3_BUCKET_NAME}

.PHONY: destroy
destroy: ## tf ファイルに記載された情報を元にリソースを削除します
	aws s3 rm s3://${S3_BUCKET_NAME} --recursive
	terraform destroy -auto-approve

api-test:
	curl https://${API_DOMAIN}/api/article/list --header 'x-api-key: ${API_KEY}'
