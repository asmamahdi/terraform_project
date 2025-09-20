#!/bin/bash

# Bash Script to Validate Terraform Configurations
# This script validates all Terraform configurations in the project

echo "🔍 Validating all Terraform configurations..."

# Function to validate environment
validate_environment() {
    local env_path="$1"
    local env_name="$2"
    
    echo "  📁 Validating $env_name environment..."
    
    if [ -d "$env_path" ]; then
        cd "$env_path"
        
        if [ -d ".terraform" ]; then
            echo "    🔄 Running terraform validate..."
            if terraform validate; then
                echo "    ✅ $env_name validation passed"
            else
                echo "    ❌ $env_name validation failed"
                return 1
            fi
        else
            echo "    ⚠️  $env_name not initialized - skipping"
        fi
        
        cd - > /dev/null
    else
        echo "    ❌ Environment directory not found: $env_path"
        return 1
    fi
}

# Main execution
environments=("dev" "staging" "prod")
validation_passed=true

for env in "${environments[@]}"; do
    env_path="environments/$env"
    if ! validate_environment "$env_path" "$env"; then
        validation_passed=false
    fi
done

echo ""
if [ "$validation_passed" = true ]; then
    echo "🎉 All validations passed!"
    exit 0
else
    echo "❌ Some validations failed!"
    exit 1
fi
