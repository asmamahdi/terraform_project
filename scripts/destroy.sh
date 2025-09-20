#!/bin/bash

# Terraform Destruction Script
# This script automates the destruction of infrastructure for different environments

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
    print_error "Usage: $0 <environment>"
    print_error "Environments: dev, staging, prod"
    exit 1
fi

ENVIRONMENT=$1

# Validate environment
if [[ ! "$ENVIRONMENT" =~ ^(dev|staging|prod)$ ]]; then
    print_error "Invalid environment: $ENVIRONMENT"
    print_error "Valid environments: dev, staging, prod"
    exit 1
fi

print_warning "=================================================="
print_warning "WARNING: This script will DESTROY all resources"
print_warning "in the $ENVIRONMENT environment!"
print_warning "This action cannot be undone!"
print_warning "=================================================="

print_warning "Are you absolutely sure you want to continue? (y/N)"
read -r response

if [[ ! "$response" =~ ^([yY][eE][sS]|[yY])$ ]]; then
    print_status "Destruction cancelled."
    exit 0
fi

print_warning "Please type 'DESTROY' to confirm:"
read -r confirmation

if [[ "$confirmation" != "DESTROY" ]]; then
    print_error "Confirmation failed. Destruction cancelled."
    exit 1
fi

print_status "Starting Terraform destruction for environment: $ENVIRONMENT"

# Change to environment directory
cd "environments/$ENVIRONMENT"

# Check if Terraform is initialized
if [ ! -d ".terraform" ]; then
    print_status "Initializing Terraform..."
    terraform init
fi

# Run terraform destroy
print_status "Running terraform destroy..."
terraform destroy -auto-approve

print_status "Terraform destruction completed for $ENVIRONMENT environment."
print_warning "All resources in $ENVIRONMENT have been destroyed!"
