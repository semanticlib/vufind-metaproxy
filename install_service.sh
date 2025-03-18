#!/bin/bash

# Variables
SOURCE_DIR="/usr/local/vufind-metaproxy"
SERVICE_FILE="$SOURCE_DIR/vufind-metaproxy.service"
LOGROTATE_FILE="$SOURCE_DIR/vufind-metaproxy.logrotate"

# Destination paths
DEST_SERVICE="/etc/systemd/system/vufind-metaproxy.service"
DEST_LOGROTATE="/etc/logrotate.d/vufind-metaproxy"

# Prompt for user and group
read -p "Enter the user to run the service: " SERVICE_USER
read -p "Enter the group to run the service: " SERVICE_GROUP

# Validate user and group
if ! id "$SERVICE_USER" &>/dev/null; then
    echo "Error: User '$SERVICE_USER' does not exist."
    exit 1
fi

if ! getent group "$SERVICE_GROUP" &>/dev/null; then
    echo "Error: Group '$SERVICE_GROUP' does not exist."
    exit 1
fi

# Update user and group in the service file
sed -i "s/User=your-username/User=$SERVICE_USER/g" "$SERVICE_FILE"
sed -i "s/Group=your-group/Group=$SERVICE_GROUP/g" "$SERVICE_FILE"

# Update user and group in the logrotate file
sed -i "s/create 0644 your-username your-group/create 0644 $SERVICE_USER $SERVICE_GROUP/g" "$LOGROTATE_FILE"

# Deploy files
echo "Deploying files..."

# Copy service file to systemd
cp "$SERVICE_FILE" "$DEST_SERVICE"

# Copy logrotate file to logrotate.d
cp "$LOGROTATE_FILE" "$DEST_LOGROTATE"

# Set permissions for log file
touch "$LOG_FILE"
chown "$SERVICE_USER:$SERVICE_GROUP" "$LOG_FILE"
chmod 644 "$LOG_FILE"

# Reload systemd and start the service
echo "Reloading systemd and starting service..."
systemctl daemon-reload
systemctl enable vufind-metaproxy
systemctl start vufind-metaproxy

# Check service status
echo "Service status:"
systemctl status vufind-metaproxy --no-pager

echo "Service installation complete!"
