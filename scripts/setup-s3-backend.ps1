# Setup S3 Backend for Terraform State Management
# This script creates the S3 backend infrastructure and migrates existing state

param(
    [Parameter(Mandatory=$true)]
    [string]$BucketName,
    
    [Parameter(Mandatory=$false)]
    [string]$Region = "us-east-1",
    
    [Parameter(Mandatory=$false)]
    [string]$DynamoDBTableName = "terraform-state-locks",
    
    # Removed CreateTerraformUser parameter to keep this Terraform-only
)

Write-Host "🚀 Setting up S3 Backend for Terraform State Management" -ForegroundColor Green
Write-Host ""

# Check if AWS CLI is configured
Write-Host "📋 Checking AWS CLI configuration..." -ForegroundColor Yellow
try {
    $awsIdentity = aws sts get-caller-identity 2>$null
    if ($LASTEXITCODE -ne 0) {
        Write-Host "❌ AWS CLI not configured or credentials invalid" -ForegroundColor Red
        Write-Host "Please run 'aws configure' first" -ForegroundColor Red
        exit 1
    }
    Write-Host "✅ AWS CLI configured successfully" -ForegroundColor Green
} catch {
    Write-Host "❌ AWS CLI not found. Please install AWS CLI first" -ForegroundColor Red
    exit 1
}

# Check if bucket name is globally unique
Write-Host "🔍 Checking if S3 bucket name is available..." -ForegroundColor Yellow
$bucketExists = aws s3api head-bucket --bucket $BucketName 2>$null
if ($LASTEXITCODE -eq 0) {
    Write-Host "❌ Bucket '$BucketName' already exists. Please choose a different name." -ForegroundColor Red
    exit 1
}
Write-Host "✅ Bucket name '$BucketName' is available" -ForegroundColor Green

# Create backend infrastructure
Write-Host "🏗️ Creating S3 backend infrastructure..." -ForegroundColor Yellow
Set-Location "environments/backend"

# Initialize and apply backend infrastructure
Write-Host "📦 Initializing Terraform for backend..." -ForegroundColor Yellow
terraform init

if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Failed to initialize Terraform" -ForegroundColor Red
    exit 1
}

Write-Host "📋 Planning backend infrastructure..." -ForegroundColor Yellow
terraform plan -var="bucket_name=$BucketName" -var="dynamodb_table_name=$DynamoDBTableName"

Write-Host "🚀 Applying backend infrastructure..." -ForegroundColor Yellow
terraform apply -auto-approve -var="bucket_name=$BucketName" -var="dynamodb_table_name=$DynamoDBTableName"

if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Failed to create backend infrastructure" -ForegroundColor Red
    exit 1
}

Write-Host "✅ Backend infrastructure created successfully!" -ForegroundColor Green

# Get backend configuration
$backendConfig = terraform output -json backend_config | ConvertFrom-Json

Write-Host ""
Write-Host "📋 Backend Configuration:" -ForegroundColor Cyan
Write-Host "  Bucket: $($backendConfig.bucket)" -ForegroundColor White
Write-Host "  Region: $($backendConfig.region)" -ForegroundColor White
Write-Host "  DynamoDB Table: $($backendConfig.dynamodb_table)" -ForegroundColor White
Write-Host "  Encrypt: $($backendConfig.encrypt)" -ForegroundColor White

# Create migration script for each environment
Write-Host ""
Write-Host "📝 Creating migration scripts for each environment..." -ForegroundColor Yellow

$environments = @("dev", "staging", "prod")

foreach ($env in $environments) {
    $migrationScript = @"
# Migrate $env environment to S3 backend
# Run this script from the project root directory

Write-Host "🔄 Migrating $env environment to S3 backend..." -ForegroundColor Yellow

# Navigate to environment directory
Set-Location "environments/$env"

# Backup current state
if (Test-Path "terraform.tfstate") {
    Copy-Item "terraform.tfstate" "terraform.tfstate.backup.$(Get-Date -Format 'yyyyMMdd-HHmmss')"
    Write-Host "✅ Current state backed up" -ForegroundColor Green
}

# Initialize with S3 backend
Write-Host "📦 Initializing with S3 backend..." -ForegroundColor Yellow
terraform init -backend-config="bucket=$($backendConfig.bucket)" -backend-config="key=$env/terraform.tfstate" -backend-config="region=$($backendConfig.region)" -backend-config="dynamodb_table=$($backendConfig.dynamodb_table)" -backend-config="encrypt=$($backendConfig.encrypt)"

if (`$LASTEXITCODE -eq 0) {
    Write-Host "✅ $env environment migrated to S3 backend successfully!" -ForegroundColor Green
} else {
    Write-Host "❌ Failed to migrate $env environment" -ForegroundColor Red
}

# Return to project root
Set-Location "../.."
"@

    $migrationScript | Out-File -FilePath "scripts/migrate-$env-to-s3.ps1" -Encoding UTF8
    Write-Host "✅ Created migration script for $env environment" -ForegroundColor Green
}

Write-Host ""
Write-Host "🎉 S3 Backend setup completed successfully!" -ForegroundColor Green
Write-Host ""
Write-Host "📋 Next Steps:" -ForegroundColor Cyan
Write-Host "1. Run the migration scripts for each environment:" -ForegroundColor White
Write-Host "   .\scripts\migrate-dev-to-s3.ps1" -ForegroundColor Gray
Write-Host "   .\scripts\migrate-staging-to-s3.ps1" -ForegroundColor Gray
Write-Host "   .\scripts\migrate-prod-to-s3.ps1" -ForegroundColor Gray
Write-Host ""
Write-Host "2. Use the S3 backend for team collaboration and state management" -ForegroundColor White
Write-Host ""
Write-Host "3. The IAM policy created can be attached to users/roles as needed" -ForegroundColor White

# Return to project root
Set-Location "../.."
