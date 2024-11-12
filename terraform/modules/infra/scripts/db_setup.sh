#!/bin/bash
set -e

# Variables
REGION="${region}"
S3_BUCKET_NAME="${s3_bucket_name}"

# Update package lists and install dependencies
apt-get update -y
apt-get install -y awscli jq gnupg curl cron

# Import the MongoDB public GPG key and create the MongoDB source list file for version 8.0
curl -fsSL https://www.mongodb.org/static/pgp/server-8.0.asc | gpg -o /usr/share/keyrings/mongodb-server-8.0.gpg --dearmor
echo "deb [ arch=amd64,arm64 signed-by=/usr/share/keyrings/mongodb-server-8.0.gpg ] https://repo.mongodb.org/apt/ubuntu jammy/mongodb-org/8.0 multiverse" | tee /etc/apt/sources.list.d/mongodb-org-8.0.list

# Install MongoDB
apt-get update -y
apt-get install -y mongodb-org

# Start and enable MongoDB service
systemctl start mongod
systemctl enable mongod

# Wait for MongoDB to start
sleep 10

# Fetch database credentials from AWS Secrets Manager
DB_CREDENTIALS=$(aws secretsmanager get-secret-value --secret-id "prod/db_credentials" --region "$REGION" --query 'SecretString' --output text)
DB_USERNAME=$(echo $DB_CREDENTIALS | jq -r '.username')
DB_PASSWORD=$(echo $DB_CREDENTIALS | jq -r '.password')

# Create admin user in MongoDB
mongosh admin --eval "db.createUser({user: '$DB_USERNAME', pwd: '$DB_PASSWORD', roles:[{role:'root',db:'admin'}]});"

# Update MongoDB configuration to allow external connections
sed -i 's/bindIp: 127.0.0.1/bindIp: 0.0.0.0/' /etc/mongod.conf

# Enable authentication in MongoDB configuration
sed -i '/#security:/a\security:\n  authorization: "enabled"' /etc/mongod.conf

# Restart MongoDB to apply changes
systemctl restart mongod

# Define the backup script exactly as in the example
backup_script="#!/bin/bash

# Define MongoDB connection details
DATE=\$(date +'%Y-%m-%d-%H-%M')
BACKUP_PATH=\"/tmp/mongodb_backup_\$DATE\"
DB_CREDENTIALS=\$(aws secretsmanager get-secret-value --secret-id \"prod/db_credentials\" --region \"$REGION\" --query \"SecretString\" --output text)
DB_USERNAME=\$(echo \$DB_CREDENTIALS | jq -r \".username\")
DB_PASSWORD=\$(echo \$DB_CREDENTIALS | jq -r \".password\")

# Create backup directory
mkdir -p \$BACKUP_PATH

# Perform MongoDB dump
mongodump --authenticationDatabase \"admin\" --username \"\$DB_USERNAME\" --password \"\$DB_PASSWORD\" --out \$BACKUP_PATH

# Compress the backup
tar -czvf /tmp/mongodb_backup_\$DATE.tar.gz -C /tmp mongodb_backup_\$DATE

# Upload to S3
aws s3 cp /tmp/mongodb_backup_\$DATE.tar.gz s3://$S3_BUCKET_NAME/backups/mongodb_backup_\$DATE.tar.gz --region \"$REGION\"

# Clean up
rm -rf \$BACKUP_PATH
rm /tmp/mongodb_backup_\$DATE.tar.gz
echo \"Backup completed successfully on \$DATE\"
"

# Write the backup script to /usr/local/bin/backup_mongodb.sh
echo "$backup_script" > /usr/local/bin/backup_mongodb.sh
chmod +x /usr/local/bin/backup_mongodb.sh

# Schedule the backup script via cron to run daily at 2 AM
(crontab -l 2>/dev/null; echo "0 2 * * * /usr/local/bin/backup_mongodb.sh >> /var/log/mongodb_backup.log 2>&1") | crontab -

# Restart cron service to ensure the new cron job is loaded
systemctl restart cron
echo "MongoDB installation, configuration, and backup setup completed successfully."