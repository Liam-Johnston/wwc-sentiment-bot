DOCKER_COMPOSE ?= docker-compose
GCLOUD = $(DOCKER_COMPOSE) run gcloud
TERRAFORM = $(DOCKER_COMPOSE) run --rm tf
BUILD = $(DOCKER_COMPOSE) run builder sh


TFSTATE_BUCKET = "$(PROJECT_ID)-tf-state"
TF_BACKEND_CONFIG = -backend-config="bucket=$(TFSTATE_BUCKET)"

.PHONY: login
login:
	$(GCLOUD) sh -c "gcloud auth application-default login --no-browser && \
	mv /root/.config/gcloud/application_default_credentials.json /out/application_default_credentials.json"

.PHONY: run_plan
run_plan: init plan

.PHONY: run_apply
run_apply: init apply

.PHONY: init
init:
	$(TERRAFORM) init -input=false $(TF_BACKEND_CONFIG)
	-$(TERRAFORM) validate
	-$(TERRAFORM) fmt

.PHONY: plan
plan:
	$(TERRAFORM) plan -out=tfplan -input=false

.PHONY: apply
apply:
	$(TERRAFORM) apply "tfplan"

.PHONY: destroy_apply
destroy_apply:
	$(TERRAFORM) destroy -auto-approve

.PHONY: build_event_handler
build_event_handler:
	@$(BUILD) -c \
		"cp -r /app/src/ /app/package.json . && \
		zip -rmq -X ./function.zip ."
