#!/bin/bash
# install_service.sh

# Default installation directory
DEFAULT_INSTALL_DIR="/usr/local/vufind-metaproxy"

# Prompt for installation directory
read -p "Enter the installation directory [default: $DEFAULT_INSTALL_DIR]: " INSTALL_DIR
INSTALL_DIR=${INSTALL_DIR:-$DEFAULT_INSTALL_DIR}

# Validate installation directory
if [ ! -d "$INSTALL_DIR" ]; then
    echo "Creating installation directory: $INSTALL_DIR"
    mkdir -p "$INSTALL_DIR" || { echo "Error: Failed to create directory '$INSTALL_DIR'"; exit 1; }
fi

# Get the directory where this script is located
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

# Copy all files from the script directory to the installation directory
echo "Copying files from '$SCRIPT_DIR' to '$INSTALL_DIR'..."
cp -r "$SCRIPT_DIR"/* "$INSTALL_DIR/" || { echo "Error: Failed to copy files"; exit 1; }

# Variables
SERVICE_FILE="$INSTALL_DIR/vufind-metaproxy.service"
LOGROTATE_FILE="$INSTALL_DIR/vufind-metaproxy.logrotate"
LOG_FILE="/var/log/vufind-metaproxy.log"

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

# Change ownership of install_dir
echo "Setting ownership of '$INSTALL_DIR' to '$SERVICE_USER:$SERVICE_GROUP'..."
chown -R "$SERVICE_USER:$SERVICE_GROUP" "$INSTALL_DIR" || { echo "Error: Failed to set ownership"; exit 1; }

# Update user and group in the service file
echo "Updating service file with user, group, and working directory..."
sed -i "s|ExecStart=.*|ExecStart=/usr/bin/metaproxy -c ${INSTALL_DIR//\//\\/}/vufind.xml|g" "$SERVICE_FILE" || { echo "Error: Failed to update ExecStart"; exit 1; }
sed -i "s|WorkingDirectory=.*|WorkingDirectory=$INSTALL_DIR|g" "$SERVICE_FILE" || { echo "Error: Failed to update WorkingDirectory"; exit 1; }
sed -i "s/User=your-username/User=$SERVICE_USER/g" "$SERVICE_FILE" || { echo "Error: Failed to update User"; exit 1; }
sed -i "s/Group=your-group/Group=$SERVICE_GROUP/g" "$SERVICE_FILE" || { echo "Error: Failed to update Group"; exit 1; }

# Update user and group in the logrotate file
echo "Updating logrotate file with user and group..."
sed -i "s/create 0644 your-username your-group/create 0644 $SERVICE_USER $SERVICE_GROUP/g" "$LOGROTATE_FILE" || { echo "Error: Failed to update logrotate file"; exit 1; }

# Deploy files using symlinks
echo "Creating symlinks for service and logrotate files..."

# Check if service file already exists in destination
if [ -f "$DEST_SERVICE" ] || [ -L "$DEST_SERVICE" ]; then
    read -p "Service file or symlink already exists at '$DEST_SERVICE'. Overwrite? [y/N]: " OVERWRITE
    if [[ ! "$OVERWRITE" =~ ^[Yy]$ ]]; then
        echo "Aborting installation."
        exit 1
    else
        rm -f "$DEST_SERVICE" || { echo "Error: Failed to remove existing service file or symlink"; exit 1; }
    fi
fi

# Create symlink for service file
echo "Creating symlink for service file at '$DEST_SERVICE'..."
ln -s "$SERVICE_FILE" "$DEST_SERVICE" || { echo "Error: Failed to create symlink for service file"; exit 1; }

# Check if logrotate file already exists in destination
if [ -f "$DEST_LOGROTATE" ] || [ -L "$DEST_LOGROTATE" ]; then
    read -p "Logrotate file or symlink already exists at '$DEST_LOGROTATE'. Overwrite? [y/N]: " OVERWRITE
    if [[ ! "$OVERWRITE" =~ ^[Yy]$ ]]; then
        echo "Aborting installation."
        exit 1
    else
        rm -f "$DEST_LOGROTATE" || { echo "Error: Failed to remove existing logrotate file or symlink"; exit 1; }
    fi
fi

# Create symlink for logrotate file
echo "Creating symlink for logrotate file at '$DEST_LOGROTATE'..."
ln -s "$LOGROTATE_FILE" "$DEST_LOGROTATE" || { echo "Error: Failed to create symlink for logrotate file"; exit 1; }

# Set permissions for log file
echo "Setting up log file at '$LOG_FILE'..."
touch "$LOG_FILE" || { echo "Error: Failed to create log file"; exit 1; }
chown "$SERVICE_USER:$SERVICE_GROUP" "$LOG_FILE" || { echo "Error: Failed to set log file ownership"; exit 1; }
chmod 644 "$LOG_FILE" || { echo "Error: Failed to set log file permissions"; exit 1; }

# Reload systemd and start the service
echo "Reloading systemd and starting service..."
systemctl daemon-reload || { echo "Error: Failed to reload systemd"; exit 1; }
systemctl enable vufind-metaproxy || { echo "Error: Failed to enable service"; exit 1; }
systemctl start vufind-metaproxy || { echo "Error: Failed to start service"; exit 1; }

# Check service status
echo "Service status:"
systemctl status vufind-metaproxy --no-pager

echo "Service installation complete!"
