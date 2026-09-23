#!/bin/bash

while true; do
    echo "========================================"
    echo "DEVOPS TOOLKIT"
    echo "========================================"
    echo "1) Server Health"
    echo "2) Network Check"
    echo "3) Service Check"
    echo "4) Logs Analyze"
    echo "5) Exit"
    echo "========================================"
    read -p "Enter your choice: " choice

    case $choice in
        1)
            echo "Running Server Health..."
            ./server-health.sh
            ;;
        2)
            read -p "Enter hostname (default google.com): " host
            if [ -z "$host" ]; then
                host="google.com"
            fi
            echo "Running Network Check for $host..."
            ./network-check.sh "$host"
            ;;
        3)
            read -p "Enter service name: " service
            if [ -n "$service" ]; then
                echo "Running Service Check for $service..."
                ./service-check.sh "$service"
            else
                echo "No service name provided!"
            fi
            ;;
        4)
            read -p "Enter file for logs: " file
            if [ -n "$file" ]; then
                echo "Running logs analyzer for $file..."
                ./log-analyzer.sh "$file"
            else
                echo "No file provided!"
            fi
            ;;
        5)
            echo "Exiting DevOps Toolkit. Goodbye!"
            break
            ;;
        *)
            echo "Invalid choice. Please try again."
            ;;
    esac
done

