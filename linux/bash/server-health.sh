#!/bin/bash
show_header(){
echo "================================"
echo " SERVER HEALTH CHECK"
echo "================================"
echo ""
}
show_system_info(){
echo "Hostname: $(hostname)"
echo "Uptime: $(uptime)"
echo "Current User: $(whoami)"
echo ""
}
show_memory(){
echo "CPU/Load:"
echo "$(ps)"
echo "Memory:"
echo "$(free -h)"
echo "Disk:"
echo "$(df -h)"
echo ""
}
show_processes(){
echo "Top Processes: $(ps aux | head)"
echo ""
}
echo "================================"
echo " CHECK COMPLETE"
echo "================================"

show_header
show_system_info
show_memory
show_processes

# 1. Get the percentage and remove the '%' sign using tr
usage=$(df -h | grep "C" | awk '{print $5}' | tail -n1 | tr -d '%')

# 2. Compare the numeric value against 78
if [ -z $1 ]; then
threshold=78 
else
threshold=$1
fi

if [ "$usage" -gt "$threshold" ]; then
    echo "Warning: Disk usage is $usage%, which is greater than 78%."
else
    echo "OK: Disk usage is $usage%, which is safe."
fi

