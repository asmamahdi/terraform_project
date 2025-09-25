# Makefile - Terraform Best Practices Project
# Owner: Asma Mahdi
# Purpose: Automation and convenience commands for Terraform project

.PHONY: help init validate format plan apply destroy clean dev staging prod validate-all

# Default target
help: ## Show this help message
	@echo "AWS Practice Environment - Terraform Best Practices Project"
	@echo "Owner: Asma Mahdi"
	@echo "================================================"
	@echo ""
	@echo "Available commands:"
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "  \033[36m%-15s\033[0m %s\n", $$1, $$2}' $(MAKEFILE_LIST)

# Environment-specific commands
dev: ## Deploy development environment
	@echo "🚀 Deploying development environment..."
	@./scripts/deploy.sh dev

staging: ## Deploy staging environment
	@echo "🚀 Deploying staging environment..."
	@./scripts/deploy.sh staging

prod: ## Deploy production environment
	@echo "🚀 Deploying production environment..."
	@./scripts/deploy.sh prod

# Destroy commands
destroy-dev: ## Destroy development environment
	@echo "🗑️  Destroying development environment..."
	@./scripts/destroy.sh dev

destroy-staging: ## Destroy staging environment
	@echo "🗑️  Destroying staging environment..."
	@./scripts/destroy.sh staging

destroy-prod: ## Destroy production environment
	@echo "🗑️  Destroying production environment..."
	@./scripts/destroy.sh prod

# Validation commands
validate: ## Validate specific environment (usage: make validate ENV=dev)
	@if [ -z "$(ENV)" ]; then \
		echo "❌ Please specify environment: make validate ENV=dev"; \
		exit 1; \
	fi
	@echo "🔍 Validating $(ENV) environment..."
	@./scripts/validate.sh $(ENV)

validate-all: ## Validate all environments and modules
	@echo "🔍 Validating all environments and modules..."
	@./scripts/validate.sh

# Terraform commands
init: ## Initialize Terraform for all environments
	@echo "🚀 Initializing Terraform..."
	@cd environments/dev && terraform init
	@cd environments/staging && terraform init
	@cd environments/prod && terraform init
	@echo "✅ Initialization complete"

format: ## Format all Terraform files
	@echo "🎨 Formatting Terraform files..."
	@find . -name "*.tf" -exec terraform fmt {} \;
	@echo "✅ Formatting complete"

# Utility commands
clean: ## Clean up Terraform files and directories
	@echo "🧹 Cleaning up Terraform files..."
	@find . -name ".terraform" -type d -exec rm -rf {} + 2>/dev/null || true
	@find . -name ".terraform.lock.hcl" -delete 2>/dev/null || true
	@find . -name "terraform.tfstate*" -delete 2>/dev/null || true
	@echo "✅ Cleanup complete"

# Development commands
plan-dev: ## Plan development environment changes
	@echo "📋 Planning development environment..."
	@cd environments/dev && terraform plan

plan-staging: ## Plan staging environment changes
	@echo "📋 Planning staging environment..."
	@cd environments/staging && terraform plan

plan-prod: ## Plan production environment changes
	@echo "📋 Planning production environment..."
	@cd environments/prod && terraform plan

# Status commands
status: ## Show status of all environments
	@echo "📊 Environment Status:"
	@echo "====================="
	@for env in dev staging prod; do \
		if [ -d "environments/$$env" ]; then \
			echo "📁 $$env: Configuration exists"; \
		else \
			echo "❌ $$env: Configuration missing"; \
		fi \
	done

# Documentation commands
docs: ## Generate documentation
	@echo "📚 Generating documentation..."
	@echo "Project structure:"
	@tree -I '.terraform|*.tfstate*|.terraform.lock.hcl' || ls -la
	@echo "✅ Documentation generated"

# Security commands
security-scan: ## Run security scan on Terraform files
	@echo "🔒 Running security scan..."
	@if command -v tflint >/dev/null 2>&1; then \
		echo "Running tflint..."; \
		tflint --init; \
		tflint; \
	else \
		echo "⚠️  tflint not installed. Install with: go install github.com/terraform-linters/tflint@latest"; \
	fi
