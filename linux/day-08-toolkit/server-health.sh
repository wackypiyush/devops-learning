#!/bin/bash

echo "========================================"
echo "SERVER HEALTH CHECK"
echo "========================================"

echo "[ SYSTEM ]"
echo "Hostname: $(hostname)"
echo "Uptime: $(uptime)"
echo "Current User: $(whoami)"

echo
echo "[ RESOURCES ]"
echo "CPU / Load:"
ps aux | head
echo
echo "Memory:"
free -h
echo
echo "Disk:"
df -h

echo
echo "[ PROCESSES ]"
echo "Running Processes:"
ps | head

echo
echo "[ PORTS ]"
echo "Listening Ports:"
ss -tulpn

echo "========================================"

