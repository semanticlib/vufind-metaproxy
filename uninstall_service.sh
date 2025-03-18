#!/bin/bash
# uninstall_service.sh

# Stop and disable the service
echo "Stopping and disabling vufind-metaproxy service..."
sudo systemctl stop vufind-metaproxy || echo "Warning: Failed to stop service (may not exist)."
sudo systemctl disable vufind-metaproxy || echo "Warning: Failed to disable service (may not exist)."

# Remove symlinks for service and logrotate files
echo "Removing symlinks..."
if [ -L "/etc/systemd/system/vufind-metaproxy.service" ]; then
    sudo rm /etc/systemd/system/vufind-metaproxy.service || echo "Error: Failed to remove service symlink."
else
    echo "Service symlink does not exist."
fi

if [ -L "/etc/logrotate.d/vufind-metaproxy" ]; then
    sudo rm /etc/logrotate.d/vufind-metaproxy || echo "Error: Failed to remove logrotate symlink."
else
    echo "Logrotate symlink does not exist."
fi

# Reload systemd
echo "Reloading systemd..."
sudo systemctl daemon-reload || echo "Error: Failed to reload systemd."

# Remove log file (optional)
read -p "Do you want to remove the log file at '/var/log/vufind-metaproxy.log'? [y/N]: " REMOVE_LOG
if [[ "$REMOVE_LOG" =~ ^[Yy]$ ]]; then
    echo "Removing log file..."
    sudo rm /var/log/vufind-metaproxy.log || echo "Error: Failed to remove log file."
else
    echo "Skipping log file removal."
fi

echo "Uninstallation complete!"
