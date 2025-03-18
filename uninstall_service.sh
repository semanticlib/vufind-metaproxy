#!/bin/bash

sudo systemctl stop vufind-metaproxy
sudo systemctl disable vufind-metaproxy
sudo rm /etc/systemd/system/vufind-metaproxy.service
sudo rm /etc/logrotate.d/vufind-metaproxy
sudo systemctl daemon-reload

echo "Uninstallation complete!"
