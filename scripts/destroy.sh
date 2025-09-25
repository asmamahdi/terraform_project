#!/bin/bash
# Destroy Script - Terraform Best Practices Project
# Owner: Asma Mahdi
# Purpose: Destroy infrastructure in specified environment

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_color() {
    printf "${1}${2}${NC}\n"
}

# Function to check prerequisites
check_prerequisites() {
    print_color $BLUE "🔍 Checking prerequisites..."
    
    # Check if Terraform is installed
    if ! command -v terraform &> /dev/null; then
        print_color $RED "❌ Terraform is not installed or not in PATH"
        exit 1
    fi
    print_color $GREEN "✅ Terraform is installed: $(terraform version | head -n1)"
    
    # Check if AWS CLI is installed
    if ! command -v aws &> /dev/null; then
        print_color $RED "❌ AWS CLI is not installed or not in PATH"
        exit 1
    fi
    print_color $GREEN "✅ AWS CLI is installed: $(aws --version)"
    
    # Check AWS credentials
    if ! aws sts get-caller-identity &> /dev/null; then
        print_color $RED "❌ AWS credentials are not configured or invalid"
        exit 1
    fi
    print_color $GREEN "✅ AWS credentials are configured"
}

# Function to destroy environment
destroy_environment() {
    local environment=$1
    local env_path="environments/$environment"
    
    if [ ! -d "$env_path" ]; then
        print_color $RED "❌ Environment directory not found: $env_path"
        exit 1
    fi
    
    print_color $RED "🗑️  Destroying $environment environment..."
    
    # Navigate to environment directory
    cd "$env_path"
    
    # Initialize Terraform
    print_color $BLUE "🚀 Initializing Terraform..."
    terraform init
    
    # Destroy infrastructure
    print_color $RED "🗑️  Destroying infrastructure..."
    terraform destroy -auto-approve
    
    print_color $GREEN "✅ Environment destroyed successfully!"
    
    # Return to project root
    cd ../..
}

# Main execution
main() {
    print_color $RED "🗑️  AWS Practice Environment Destroy Script"
    print_color $YELLOW "Owner: Asma Mahdi"
    print_color $RED "================================================"
    
    # Check if environment is provided
    if [ $# -eq 0 ]; then
        print_color $RED "❌ No environment specified"
        print_color $YELLOW "Usage: $0 <environment>"
        print_color $YELLOW "Available environments: dev, staging, prod"
        exit 1
    fi
    
    local environment=$1
    
    # Validate environment
    case $environment in
        dev|staging|prod)
            ;;
        *)
            print_color $RED "❌ Invalid environment: $environment"
            print_color $YELLOW "Available environments: dev, staging, prod"
            exit 1
            ;;
    esac
    
    # Confirmation prompt
    print_color $YELLOW "⚠️  WARNING: This will destroy all infrastructure in the $environment environment!"
    read -p "Are you sure you want to continue? (yes/no): " confirm
    
    if [ "$confirm" != "yes" ]; then
        print_color $YELLOW "❌ Operation cancelled"
        exit 0
    fi
    
    check_prerequisites
    destroy_environment "$environment"
}

# Run main function with all arguments
main "$@"
