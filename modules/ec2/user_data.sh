#!/bin/bash

# User Data Script for EC2 instances
# This script prepares the instance for Ansible management

set -e

# Update system
yum update -y

# Install essential packages
yum install -y \
    python3 \
    python3-pip \
    git \
    htop \
    vim \
    curl \
    wget \
    unzip

# Install AWS CLI v2
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
./aws/install
rm -rf aws awscliv2.zip

# Install CloudWatch agent
yum install -y amazon-cloudwatch-agent

# Create ansible user (optional - for dedicated Ansible management)
useradd -m -s /bin/bash ansible
echo 'ansible ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers

# Create application directory
mkdir -p /opt/${app_name}
chown ec2-user:ec2-user /opt/${app_name}

# Configure CloudWatch agent
cat > /opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent.json << EOF
{
    "logs": {
        "logs_collected": {
            "files": {
                "collect_list": [
                    {
                        "file_path": "/var/log/messages",
                        "log_group_name": "/aws/ec2/${environment}",
                        "log_stream_name": "{instance_id}/messages"
                    },
                    {
                        "file_path": "/var/log/secure",
                        "log_group_name": "/aws/ec2/${environment}",
                        "log_stream_name": "{instance_id}/secure"
                    }
                ]
            }
        }
    },
    "metrics": {
        "namespace": "CWAgent",
        "metrics_collected": {
            "cpu": {
                "measurement": [
                    "cpu_usage_idle",
                    "cpu_usage_iowait",
                    "cpu_usage_user",
                    "cpu_usage_system"
                ],
                "metrics_collection_interval": 60
            },
            "disk": {
                "measurement": [
                    "used_percent"
                ],
                "metrics_collection_interval": 60,
                "resources": [
                    "*"
                ]
            },
            "mem": {
                "measurement": [
                    "mem_used_percent"
                ],
                "metrics_collection_interval": 60
            }
        }
    }
}
EOF

# Start CloudWatch agent
/opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl \
    -a fetch-config \
    -m ec2 \
    -c file:/opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent.json \
    -s

# Create a simple health check endpoint (for load balancer)
cat > /opt/${app_name}/health.html << EOF
<!DOCTYPE html>
<html>
<head>
    <title>Health Check</title>
</head>
<body>
    <h1>Instance is healthy</h1>
    <p>Environment: ${environment}</p>
    <p>Instance ID: $(curl -s http://169.254.169.254/latest/meta-data/instance-id)</p>
    <p>Timestamp: $(date)</p>
</body>
</html>
EOF

# Install and start a simple web server for health checks
python3 -m http.server 8080 --directory /opt/${app_name} &
echo "python3 -m http.server 8080 --directory /opt/${app_name}" >> /etc/rc.local
chmod +x /etc/rc.local

# Log completion
echo "User data script completed at $(date)" >> /var/log/user-data.log

