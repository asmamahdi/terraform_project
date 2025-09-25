#!/bin/bash
# Validate Script - Terraform Best Practices Project
# Owner: Asma Mahdi
# Purpose: Validate Terraform configurations across all environments

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
}

# Function to validate modules
validate_modules() {
    print_color $BLUE "🔍 Validating Terraform modules..."
    
    local modules=("vpc" "alb" "ec2" "rds" "s3")
    local failed_modules=()
    
    for module in "${modules[@]}"; do
        print_color $BLUE "🔍 Validating $module module..."
        
        if [ -d "modules/$module" ]; then
            cd "modules/$module"
            
            # Initialize Terraform
            terraform init -backend=false > /dev/null 2>&1
            
            # Validate configuration
            if terraform validate; then
                print_color $GREEN "✅ $module module is valid"
            else
                print_color $RED "❌ $module module validation failed"
                failed_modules+=("$module")
            fi
            
            # Format check
            if terraform fmt -check=true -diff=true; then
                print_color $GREEN "✅ $module module is properly formatted"
            else
                print_color $YELLOW "⚠️  $module module needs formatting (run terraform fmt)"
            fi
            
            cd ../..
        else
            print_color $RED "❌ Module directory not found: modules/$module"
            failed_modules+=("$module")
        fi
    done
    
    if [ ${#failed_modules[@]} -gt 0 ]; then
        print_color $RED "❌ Validation failed for modules: ${failed_modules[*]}"
        return 1
    fi
    
    return 0
}

# Function to validate environment
validate_environment() {
    local environment=$1
    local env_path="environments/$environment"
    
    if [ ! -d "$env_path" ]; then
        print_color $RED "❌ Environment directory not found: $env_path"
        return 1
    fi
    
    print_color $BLUE "🔍 Validating $environment environment..."
    
    # Navigate to environment directory
    cd "$env_path"
    
    # Initialize Terraform
    print_color $BLUE "🚀 Initializing Terraform..."
    terraform init -backend=false > /dev/null 2>&1
    
    # Validate configuration
    if terraform validate; then
        print_color $GREEN "✅ $environment environment configuration is valid"
    else
        print_color $RED "❌ $environment environment validation failed"
        cd ../..
        return 1
    fi
    
    # Format check
    if terraform fmt -check=true -diff=true; then
        print_color $GREEN "✅ $environment environment is properly formatted"
    else
        print_color $YELLOW "⚠️  $environment environment needs formatting (run terraform fmt)"
    fi
    
    # Return to project root
    cd ../..
    
    return 0
}

# Function to validate all environments
validate_all_environments() {
    print_color $BLUE "🔍 Validating all environments..."
    
    local environments=("dev" "staging" "prod")
    local failed_environments=()
    
    for env in "${environments[@]}"; do
        if ! validate_environment "$env"; then
            failed_environments+=("$env")
        fi
    done
    
    if [ ${#failed_environments[@]} -gt 0 ]; then
        print_color $RED "❌ Validation failed for environments: ${failed_environments[*]}"
        return 1
    fi
    
    return 0
}

# Main execution
main() {
    print_color $BLUE "🔍 AWS Practice Environment Validation Script"
    print_color $YELLOW "Owner: Asma Mahdi"
    print_color $BLUE "================================================"
    
    check_prerequisites
    
    # Validate modules first
    if ! validate_modules; then
        print_color $RED "❌ Module validation failed"
        exit 1
    fi
    
    # Validate environments
    if [ $# -eq 0 ]; then
        # Validate all environments
        if ! validate_all_environments; then
            print_color $RED "❌ Environment validation failed"
            exit 1
        fi
    else
        # Validate specific environment
        local environment=$1
        case $environment in
            dev|staging|prod)
                if ! validate_environment "$environment"; then
                    print_color $RED "❌ $environment environment validation failed"
                    exit 1
                fi
                ;;
            *)
                print_color $RED "❌ Invalid environment: $environment"
                print_color $YELLOW "Available environments: dev, staging, prod"
                exit 1
                ;;
        esac
    fi
    
    print_color $GREEN "✅ All validations passed successfully!"
}

# Run main function with all arguments
main "$@"
