#!/bin/bash

# Setup S3 Backend for Terraform State Management
# This script creates the S3 backend infrastructure and migrates existing state

set -e

# Default values
REGION="us-east-1"
DYNAMODB_TABLE_NAME="terraform-state-locks"
# Removed CREATE_TERRAFORM_USER to keep this Terraform-only

# Function to display usage
usage() {
    echo "Usage: $0 -b BUCKET_NAME [-r REGION] [-d DYNAMODB_TABLE] [-u]"
    echo ""
    echo "Options:"
    echo "  -b BUCKET_NAME        Name of the S3 bucket (must be globally unique)"
    echo "  -r REGION            AWS region (default: us-east-1)"
    echo "  -d DYNAMODB_TABLE    DynamoDB table name (default: terraform-state-locks)"
    # Removed -u option to keep this Terraform-only
    echo "  -h                   Show this help message"
    echo ""
    echo "Example:"
    echo "  $0 -b my-terraform-state-bucket-2024 -r us-west-2"
    exit 1
}

# Parse command line arguments
while getopts "b:r:d:h" opt; do
    case $opt in
        b) BUCKET_NAME="$OPTARG" ;;
        r) REGION="$OPTARG" ;;
        d) DYNAMODB_TABLE_NAME="$OPTARG" ;;
        h) usage ;;
        *) usage ;;
    esac
done

# Check if bucket name is provided
if [ -z "$BUCKET_NAME" ]; then
    echo "❌ Error: Bucket name is required"
    usage
fi

echo "🚀 Setting up S3 Backend for Terraform State Management"
echo ""

# Check if AWS CLI is configured
echo "📋 Checking AWS CLI configuration..."
if ! aws sts get-caller-identity >/dev/null 2>&1; then
    echo "❌ AWS CLI not configured or credentials invalid"
    echo "Please run 'aws configure' first"
    exit 1
fi
echo "✅ AWS CLI configured successfully"

# Check if bucket name is globally unique
echo "🔍 Checking if S3 bucket name is available..."
if aws s3api head-bucket --bucket "$BUCKET_NAME" 2>/dev/null; then
    echo "❌ Bucket '$BUCKET_NAME' already exists. Please choose a different name."
    exit 1
fi
echo "✅ Bucket name '$BUCKET_NAME' is available"

# Create backend infrastructure
echo "🏗️ Creating S3 backend infrastructure..."
cd environments/backend

# Initialize and apply backend infrastructure
echo "📦 Initializing Terraform for backend..."
terraform init

echo "📋 Planning backend infrastructure..."
terraform plan \
    -var="bucket_name=$BUCKET_NAME" \
    -var="dynamodb_table_name=$DYNAMODB_TABLE_NAME"

echo "🚀 Applying backend infrastructure..."
terraform apply -auto-approve \
    -var="bucket_name=$BUCKET_NAME" \
    -var="dynamodb_table_name=$DYNAMODB_TABLE_NAME"

echo "✅ Backend infrastructure created successfully!"

# Get backend configuration
echo ""
echo "📋 Backend Configuration:"
terraform output -json backend_config | jq -r '
    "  Bucket: " + .bucket,
    "  Region: " + .region,
    "  DynamoDB Table: " + .dynamodb_table,
    "  Encrypt: " + (.encrypt | tostring)
'

# Create migration script for each environment
echo ""
echo "📝 Creating migration scripts for each environment..."

environments=("dev" "staging" "prod")

for env in "${environments[@]}"; do
    cat > "../scripts/migrate-${env}-to-s3.sh" << EOF
#!/bin/bash

# Migrate $env environment to S3 backend
# Run this script from the project root directory

set -e

echo "🔄 Migrating $env environment to S3 backend..."

# Navigate to environment directory
cd "environments/$env"

# Backup current state
if [ -f "terraform.tfstate" ]; then
    cp "terraform.tfstate" "terraform.tfstate.backup.\$(date +%Y%m%d-%H%M%S)"
    echo "✅ Current state backed up"
fi

# Initialize with S3 backend
echo "📦 Initializing with S3 backend..."
terraform init \\
    -backend-config="bucket=$BUCKET_NAME" \\
    -backend-config="key=$env/terraform.tfstate" \\
    -backend-config="region=$REGION" \\
    -backend-config="dynamodb_table=$DYNAMODB_TABLE_NAME" \\
    -backend-config="encrypt=true"

if [ \$? -eq 0 ]; then
    echo "✅ $env environment migrated to S3 backend successfully!"
else
    echo "❌ Failed to migrate $env environment"
    exit 1
fi

# Return to project root
cd "../.."
EOF

    chmod +x "../scripts/migrate-${env}-to-s3.sh"
    echo "✅ Created migration script for $env environment"
done

echo ""
echo "🎉 S3 Backend setup completed successfully!"
echo ""
echo "📋 Next Steps:"
echo "1. Run the migration scripts for each environment:"
echo "   ./scripts/migrate-dev-to-s3.sh"
echo "   ./scripts/migrate-staging-to-s3.sh"
echo "   ./scripts/migrate-prod-to-s3.sh"
echo ""
echo "2. Use the S3 backend for team collaboration and state management"
echo ""
echo "3. The IAM policy created can be attached to users/roles as needed"

# Return to project root
cd "../.."
