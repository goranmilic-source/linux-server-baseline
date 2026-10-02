.DEFAULT_GOAL := help
SHELL := /bin/bash

COMPOSE := docker compose
SERVICE ?= api

.PHONY: help up down lint test check

help: ## Show available commands
	@grep -E '^[a-zA-Z_-]+:.*## ' $(MAKEFILE_LIST) | \
	awk 'BEGIN {FS = ":.*## "}; {printf "  \033[36m%-10s\033[0m %s\n", $$1, $$2}'

up: ## Start the stack in the background
	$(COMPOSE) up -d

down: ## Stop the stack
	$(COMPOSE) down

lint: ## Check code style
	$(COMPOSE) exec $(SERVICE) ruff check .

test: ## Run tests with Pytest
	$(COMPOSE) exec $(SERVICE) pytest -q

check: ## Runs the pre-commit checks for astethics and git leaks.
	pre-commit run --all-files

deploy: ## Runs the Ansible playbook that checks the availability of servers.
	ansible-playbook site.yaml -K
