GCLOUD = docker-compose run gcloud
TERRAFORM = docker-compose run --rm tf

.PHONY: env
env:
	@cp .env.template .env

.PHONY: login
login:
	$(GCLOUD) sh -c "gcloud auth application-default login && \
	mv /root/.config/gcloud/application_default_credentials.json /out/application_default_credentials.json"

.PHONY: run_plan
run_plan: init plan

.PHONY: run_apply
run_apply: init apply

.PHONY: init
init:
	$(TERRAFORM) init -input=false
	$(TERRAFORM) validate
	$(TERRAFORM) fmt
	-@docker-compose run --entrypoint sh tf /scripts/import_app_engine.sh > /dev/null

.PHONY: plan
plan:
	$(TERRAFORM) plan -out=tfplan -input=false

.PHONY: apply
apply:
	$(TERRAFORM) apply "tfplan"

.PHONY: destroy_apply
destroy_apply:
	$(TERRAFORM) destroy -auto-approve

.PHONY: build_entry_point
build_entry_point:
	@docker-compose run \
		ep-builder sh -c \
		"cp -r /app/src/ /app/package.json . && \
		zip -rmq -X ./function.zip ."

.PHONY: build_sentiment_bot
build_sentiment_bot:
	@docker-compose run \
		sb-builder sh -c \
		"cp -r /app/src/ /app/package.json . && \
		zip -rmq -X ./function.zip ."

.PHONY: build_all
build_all: build_entry_point build_sentiment_bot

.PHONY: deploy
deploy: build_all init plan apply

.PHONY: infra_deploy
infra_deploy: init plan apply
