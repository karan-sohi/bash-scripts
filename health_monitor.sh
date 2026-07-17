#!/bin/bash

echo "=========================="
echo " Server Health Report"
echo "=========================="

echo "Hostname:"
hostname

echo ""

echo "Date:"
date

echo ""

CPU_IDLE=$(top -bn1 | grep "Cpu" | awk '{print $8}')
CPU_USAGE=$(echo "100 - $CPU_IDLE" | bc)

echo "CPU Usage: $CPU_USAGE%"


MEMORY_USAGE=$(free | awk '/Mem/ {printf "%.2f", $3/$2 * 100}')

echo "Memory Usage: $MEMORY_USAGE%"


DISK_USAGE=$(df / | awk 'NR==2 {print $5}' | sed 's/%//')

echo "Disk Usage: $DISK_USAGE%"


if [ $DISK_USAGE -gt 80 ]
then
    echo "WARNING: Disk usage above 80%"
fi


echo ""

echo "Failed Services:"
systemctl --failed


echo ""

if ping -c 2 google.com > /dev/null
then
    echo "Network: OK"
else
    echo "Network: FAILED"
fi