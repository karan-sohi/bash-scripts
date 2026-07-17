#!/bin/bash

LOG_FILE="health_report.log"
exec >> "$LOG_FILE" 2>&1

if [ -f config.conf ] 
then
    echo "ERROR: config.conf not found"
    exit 1
fi
source config.conf

echo "=========================="
echo " New Health Check Run"
echo "=========================="
echo "Run Time $(date +"%A, %B %d, %Y %I:%M:%S %p")"
echo "Run Time: $(date +"%A, %B %d, %Y %I:%M:%S %p")"
HOSTNAME=$(hostname)
CURRENT_DATE=$(date)

echo "Hostname: $HOSTNAME"
echo "Date: $CURRENT_DATE"

WARNING_COUNT=0


check_threshold() {
    local metric=$1
    local value=$2
    local threshold=$3

    echo "$metric Usage: ${value}%"

    if [ "$value" -ge "$threshold" ] 
    then
    echo "WARNING: $metric usage above ${threshold}%"
    WARNING_COUNT=$((WARNING_COUNT+1))
    fi

}

CPU_IDLE=$(top -bn1 | grep "Cpu" | awk '{print $8}')
CPU_USAGE=$(echo "100 - $CPU_IDLE" | bc | awk '{printf "%.0f", $1}')


MEMORY_USAGE=$(free | awk '/Mem/ {printf "%.0f", $3/$2 * 100}')


DISK_USAGE=$(df / | awk 'NR==2 {print $5}' | sed 's/%//')


check_threshold "Memory"  "$MEMORY_USAGE" "$MEMORY_THRESHOLD"

check_threshold "Disk" "$DISK_USAGE" "$DISK_THRESHOLD"

check_threshold "CPU" "$CPU_USAGE" "$CPU_THRESHOLD"


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

echo ""
echo "Total Warnings: ${WARNING_COUNT}"



if [ "$WARNING_COUNT" -gt 0 ]
then
    exit 1
else
    exit 0
fi