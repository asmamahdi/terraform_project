# Terraform Project Makefile
# This Makefile provides common commands for managing the Terraform infrastructure

.PHONY: help init plan apply destroy validate fmt clean deploy-staging deploy-prod migrate-backend

# Default target
help:
	@echo "Terraform Project Management Commands:"
	@echo ""
	@echo "Environment Management:"
	@echo "  init-dev          Initialize Terraform for dev environment"
	@echo "  init-staging      Initialize Terraform for staging environment"
	@echo "  init-prod         Initialize Terraform for production environment"
	@echo ""
	@echo "Planning:"
	@echo "  plan-dev          Plan changes for dev environment"
	@echo "  plan-staging      Plan changes for staging environment"
	@echo "  plan-prod         Plan changes for production environment"
	@echo ""
	@echo "Deployment:"
	@echo "  apply-dev         Apply changes to dev environment"
	@echo "  apply-staging     Apply changes to staging environment"
	@echo "  apply-prod        Apply changes to production environment"
	@echo ""
	@echo "Destruction:"
	@echo "  destroy-dev       Destroy dev environment"
	@echo "  destroy-staging   Destroy staging environment"
	@echo "  destroy-prod      Destroy production environment"
	@echo ""
	@echo "Utility:"
@echo "  validate          Validate all Terraform configurations"
@echo "  fmt               Format all Terraform files"
@echo "  clean             Clean up temporary files"
@echo "  deploy-staging    Deploy to staging (plan + apply)"
@echo "  deploy-prod       Deploy to production (plan + apply)"
@echo ""
@echo "Backend Management:"
@echo "  setup-backend     Setup S3 backend infrastructure"
@echo "  init-backend      Initialize backend environment"
@echo "  plan-backend      Plan backend infrastructure"
@echo "  apply-backend     Apply backend infrastructure"
@echo "  destroy-backend   Destroy backend infrastructure"
@echo "  migrate-backend   Migrate all environments to S3 backend"

# Initialize environments
init-dev:
	@echo "Initializing Terraform for dev environment..."
	cd environments/dev && terraform init

init-staging:
	@echo "Initializing Terraform for staging environment..."
	cd environments/staging && terraform init

init-prod:
	@echo "Initializing Terraform for production environment..."
	cd environments/prod && terraform init

# Plan changes
plan-dev:
	@echo "Planning changes for dev environment..."
	cd environments/dev && terraform plan

plan-staging:
	@echo "Planning changes for staging environment..."
	cd environments/staging && terraform plan

plan-prod:
	@echo "Planning changes for production environment..."
	cd environments/prod && terraform plan

# Apply changes
apply-dev:
	@echo "Applying changes to dev environment..."
	cd environments/dev && terraform apply -auto-approve

apply-staging:
	@echo "Applying changes to staging environment..."
	cd environments/staging && terraform apply -auto-approve

apply-prod:
	@echo "Applying changes to production environment..."
	cd environments/prod && terraform apply -auto-approve

# Destroy environments
destroy-dev:
	@echo "Destroying dev environment..."
	cd environments/dev && terraform destroy -auto-approve

destroy-staging:
	@echo "Destroying staging environment..."
	cd environments/staging && terraform destroy -auto-approve

destroy-prod:
	@echo "Destroying production environment..."
	cd environments/prod && terraform destroy -auto-approve

# Validate configurations
validate:
	@echo "Validating all Terraform configurations..."
	./scripts/validate.sh

# Format Terraform files
fmt:
	@echo "Formatting Terraform files..."
	@find . -name "*.tf" -exec terraform fmt {} \;
	@echo "Formatting complete!"

# Clean up temporary files
clean:
	@echo "Cleaning up temporary files..."
	@find . -name ".terraform" -type d -exec rm -rf {} + 2>/dev/null || true
	@find . -name "*.tfstate" -delete 2>/dev/null || true
	@find . -name "*.tfstate.backup" -delete 2>/dev/null || true
	@find . -name "*.tfplan" -delete 2>/dev/null || true
	@echo "Cleanup complete!"

# Deploy to staging (plan + apply)
deploy-staging: plan-staging
	@echo "Deploying to staging environment..."
	@read -p "Do you want to apply these changes to staging? (y/N): " confirm && \
	if [ "$$confirm" = "y" ] || [ "$$confirm" = "Y" ]; then \
		$(MAKE) apply-staging; \
	else \
		echo "Deployment cancelled."; \
	fi

# Deploy to production (plan + apply)
deploy-prod: plan-prod
	@echo "Deploying to production environment..."
	@read -p "Do you want to apply these changes to production? (y/N): " confirm && \
	if [ "$$confirm" = "y" ] || [ "$$confirm" = "Y" ]; then \
		$(MAKE) apply-prod; \
	else \
		echo "Deployment cancelled."; \
	fi

# Show current status
status:
	@echo "Current Terraform Status:"
	@echo ""
	@echo "Dev Environment:"
	@cd environments/dev && terraform show -json 2>/dev/null | jq -r '.values.root_module.resources[].name' 2>/dev/null || echo "No resources or not initialized"
	@echo ""
	@echo "Staging Environment:"
	@cd environments/staging && terraform show -json 2>/dev/null | jq -r '.values.root_module.resources[].name' 2>/dev/null || echo "No resources or not initialized"
	@echo ""
	@echo "Production Environment:"
	@cd environments/prod && terraform show -json 2>/dev/null | jq -r '.values.root_module.resources[].name' 2>/dev/null || echo "No resources or not initialized"

# Install dependencies (requires jq for status command)
install-deps:
	@echo "Installing dependencies..."
	@if command -v jq >/dev/null 2>&1; then \
		echo "jq is already installed"; \
	else \
		echo "Please install jq for JSON processing: https://stedolan.github.io/jq/download/"; \
	fi
	@if command -v terraform >/dev/null 2>&1; then \
		echo "Terraform is already installed"; \
	else \
		echo "Please install Terraform: https://www.terraform.io/downloads.html"; \
	fi

# Backend Management
setup-backend:
	@echo "Setting up S3 backend infrastructure..."
	@echo "Usage: make setup-backend BUCKET_NAME=your-bucket-name"
	@if [ -z "$(BUCKET_NAME)" ]; then \
		echo "Error: BUCKET_NAME is required"; \
		echo "Example: make setup-backend BUCKET_NAME=my-terraform-state-bucket"; \
		exit 1; \
	fi
	@if command -v pwsh >/dev/null 2>&1; then \
		pwsh ./scripts/setup-s3-backend.ps1 -BucketName $(BUCKET_NAME); \
	elif command -v powershell >/dev/null 2>&1; then \
		powershell ./scripts/setup-s3-backend.ps1 -BucketName $(BUCKET_NAME); \
	else \
		./scripts/setup-s3-backend.sh -b $(BUCKET_NAME); \
	fi

init-backend:
	@echo "Initializing Terraform for backend environment..."
	cd environments/backend && terraform init

plan-backend:
	@echo "Planning backend infrastructure..."
	cd environments/backend && terraform plan

apply-backend:
	@echo "Applying backend infrastructure..."
	cd environments/backend && terraform apply

destroy-backend:
	@echo "Destroying backend infrastructure..."
	cd environments/backend && terraform destroy

# Migrate to S3 backend
migrate-backend:
	@echo "Migrating all environments to S3 backend..."
	@echo "Note: Run 'make setup-backend' first to create the S3 backend"
	@echo "Then run the individual migration scripts:"
	@echo "  ./scripts/migrate-dev-to-s3.sh"
	@echo "  ./scripts/migrate-staging-to-s3.sh"
	@echo "  ./scripts/migrate-prod-to-s3.sh"
