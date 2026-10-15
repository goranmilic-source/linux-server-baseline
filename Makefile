.DEFAULT_GOAL := help
SHELL := /bin/bash

COMPOSE := docker compose
SERVICE ?= api

.PHONY: help up down lint test check

help: ## Show available commands
	@grep -E '^[a-zA-Z_-]+:.*## ' $(MAKEFILE_LIST) | \
	awk 'BEGIN {FS = ":.*## "}; {printf "  \033[36m%-10s\033[0m %s\n", $$1, $$2}'

lint: ## Run all linters (same command CI runs)
	yamllint .
	ansible-lint
	shellcheck roles/*/files/*.sh

test: ## Run tests with Pytest
	$(COMPOSE) exec $(SERVICE) pytest -q

ssh_keys: ## Creates the SSH keys based on the users from the /roles/users/defaults/main.yml file
	./scripts/gen_user_ssh_keys.sh

check: ## Runs the pre-commit checks for astethics and git leaks.
	pre-commit run --all-files

deploy: ## Runs the Ansible playbook that checks the availability of servers.
	ansible-playbook site.yaml -K

verify: ## Runs the verify-idempotency script
	./scripts/verify-idempotency.sh -K

up: ## Start the stack in the background
	$(COMPOSE) up -d

down: ## Stop the stack
	$(COMPOSE) down
