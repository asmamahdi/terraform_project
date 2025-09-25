#!/bin/bash -xe
# User Data Script for Web Application EC2 Instances
# Owner: Asma Mahdi

# Update system
yum update -y

# Install Apache, PHP, MySQL client and AWS CLI
yum install -y httpd php php-pdo php-mysqlnd awscli

# Start and enable Apache
systemctl start httpd
systemctl enable httpd

# Create health check endpoint
echo "OK" > /var/www/html/health

# Create enhanced index page with DB and S3 connectivity
cat > /var/www/html/index.php <<EOF
<?php
echo "<h1>AWS Practice Environment - WORKING!</h1>";
echo "<h2>Environment: ${environment}</h2>";
echo "<p>Instance ID: " . @file_get_contents('http://169.254.169.254/latest/meta-data/instance-id') . "</p>";
echo "<p>Availability Zone: " . @file_get_contents('http://169.254.169.254/latest/meta-data/placement/availability-zone') . "</p>";
echo "<p>Server Time: " . date('Y-m-d H:i:s') . "</p>";

// Database connection test with diagnostics
\$db_host = "${db_endpoint}";
\$db_name = "${db_name}";
\$db_user = "${db_username}";
\$db_pass = "${db_password}";

if (!empty(\$db_host)) {
    echo "<p><strong>Database Test:</strong> \$db_host</p>";
    
    // Test port connectivity first
    \$connection = @fsockopen(\$db_host, 3306, \$errno, \$errstr, 5);
    if (\$connection) {
        fclose(\$connection);
        echo "<p style='color: blue;'>🔵 Port 3306 is reachable</p>";
        
        // Now test MySQL connection
        try {
            \$pdo = new PDO("mysql:host=\$db_host;dbname=\$db_name;charset=utf8mb4", \$db_user, \$db_pass, [
                PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION,
                PDO::ATTR_TIMEOUT => 5
            ]);
            echo "<p style='color: green;'>✅ Database connection: SUCCESS</p>";
        } catch(PDOException \$e) {
            echo "<p style='color: red;'>❌ Database connection: FAILED - " . \$e->getMessage() . "</p>";
        }
    } else {
        echo "<p style='color: red;'>❌ Port 3306 not reachable: \$errstr (\$errno)</p>";
    }
} else {
    echo "<p style='color: orange;'>⚠️ Database: Not configured</p>";
}

// S3 connection test with better diagnostics
\$s3_bucket = "${s3_bucket}";
if (!empty(\$s3_bucket)) {
    echo "<p><strong>S3 Test:</strong> \$s3_bucket</p>";
    
    // Check IAM permissions first
    \$iam_test = @shell_exec("aws sts get-caller-identity --region ${region} 2>&1");
    if (stripos(\$iam_test, 'error') === false && !empty(\$iam_test)) {
        echo "<p style='color: blue;'>🔵 IAM credentials working</p>";
        
        // Test S3 access
        \$s3_test = @shell_exec("aws s3 ls s3://\$s3_bucket --region ${region} 2>&1");
        if (stripos(\$s3_test, 'error') === false && stripos(\$s3_test, 'AccessDenied') === false) {
            echo "<p style='color: green;'>✅ S3 connection: SUCCESS</p>";
        } else {
            echo "<p style='color: red;'>❌ S3 access: \$s3_test</p>";
        }
    } else {
        echo "<p style='color: red;'>❌ IAM credentials issue: \$iam_test</p>";
    }
} else {
    echo "<p style='color: orange;'>⚠️ S3: Not configured</p>";
}

echo "<p style='color: green;'><strong>🎉 This server is healthy and responding!</strong></p>";
?>
EOF

# Set permissions
chown -R apache:apache /var/www/html
chmod -R 755 /var/www/html

# Ensure Apache is running
systemctl restart httpd
systemctl status httpd

# Log completion
echo "User data script completed successfully at $(date)" >> /var/log/user-data.log
