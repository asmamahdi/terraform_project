#!/bin/bash

# Terraform Deployment Script
# This script automates the deployment process for different environments

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if environment is provided
if [ $# -eq 0 ]; then
    print_error "Usage: $0 <environment> [plan|apply|destroy]"
    print_error "Environments: dev, staging, prod"
    print_error "Actions: plan (default), apply, destroy"
    exit 1
fi

ENVIRONMENT=$1
ACTION=${2:-plan}

# Validate environment
if [[ ! "$ENVIRONMENT" =~ ^(dev|staging|prod)$ ]]; then
    print_error "Invalid environment: $ENVIRONMENT"
    print_error "Valid environments: dev, staging, prod"
    exit 1
fi

# Validate action
if [[ ! "$ACTION" =~ ^(plan|apply|destroy)$ ]]; then
    print_error "Invalid action: $ACTION"
    print_error "Valid actions: plan, apply, destroy"
    exit 1
fi

print_status "Starting Terraform deployment for environment: $ENVIRONMENT"
print_status "Action: $ACTION"

# Change to environment directory
cd "environments/$ENVIRONMENT"

# Check if Terraform is initialized
if [ ! -d ".terraform" ]; then
    print_status "Initializing Terraform..."
    terraform init
fi

# Run Terraform command
case $ACTION in
    plan)
        print_status "Running terraform plan..."
        terraform plan
        ;;
    apply)
        print_warning "Are you sure you want to apply changes to $ENVIRONMENT? (y/N)"
        read -r response
        if [[ "$response" =~ ^([yY][eE][sS]|[yY])$ ]]; then
            print_status "Running terraform apply..."
            terraform apply -auto-approve
        else
            print_status "Deployment cancelled."
            exit 0
        fi
        ;;
    destroy)
        print_warning "Are you sure you want to destroy $ENVIRONMENT? This action cannot be undone! (y/N)"
        read -r response
        if [[ "$response" =~ ^([yY][eE][sS]|[yY])$ ]]; then
            print_status "Running terraform destroy..."
            terraform destroy -auto-approve
        else
            print_status "Destruction cancelled."
            exit 0
        fi
        ;;
esac

print_status "Terraform $ACTION completed for $ENVIRONMENT environment."
