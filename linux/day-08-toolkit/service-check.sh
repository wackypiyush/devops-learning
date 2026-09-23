#!/bin/bash

# Check if service name is provided
if [ -z "$1" ]; then
    echo "Usage: $0 <service-name>"
    exit 1
fi

service=$1

echo "========================================"
echo "SERVICE CHECK"
echo "========================================"
echo "Service name: $service"

echo
echo "[ ACTIVE ]"
systemctl is-active "$service"

echo
echo "[ ENABLED ]"
systemctl is-enabled "$service"

echo
echo "[ STATUS ]"
systemctl status "$service" --no-pager | head -n 10

echo
echo "[ RECENT LOGS ]"
journalctl -u "$service" -n 10 --no-pager

echo
echo "========================================"

