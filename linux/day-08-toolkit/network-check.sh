#!/bin/bash

if [ -z "$1" ]; then
    host="google.com"
else
    host="$1"
fi

echo "========================================"
echo "NETWORK CHECK"
echo "========================================"
echo "Host: $host"

echo
echo "[ DNS ]"
ips=$(getent ahostsv4 "$host" | awk 'NR==1{ print $1 }')
if [ -n "$ips" ]; then
    echo "DNS: OK"
    echo "IP(s): $ips"
else
    echo "DNS: FAIL"
fi

echo
echo "[ CONNECTIVITY ]"
if ping -c 2 "$host" > /dev/null 2>&1; then
    echo "Ping: OK"
else
    echo "Ping: FAIL"
fi

echo
echo "[ ROUTING ]"
if [ -n "$ips" ]; then
    for ip in $ips; do
        if ip route get "$ip" > /dev/null 2>&1; then
            echo "Route to $ip: OK"
        else
            echo "Route to $ip: FAIL"
        fi
    done
else
    echo "Route: SKIPPED (no IP)"
fi

echo
echo "[ HTTP ]"
if curl -s --head "https://$host" | grep "200" > /dev/null; then
    echo "HTTP: OK"
else
    echo "HTTP: FAIL"
fi

echo
echo "========================================"

