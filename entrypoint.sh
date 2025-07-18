#!/bin/sh
set -e

# Write out the cron job
CRON_FILE=/etc/cron.d/myscript

echo "$CRON_SCHEDULE root /bin/sh $SCRIPT_PATH >> /var/log/cron.log 2>&1" > $CRON_FILE
chmod 0644 $CRON_FILE
crontab $CRON_FILE

# Ensure log file exists
mkdir -p /var/log
: > /var/log/cron.log

# Start cron in the background
cron

# Tail the log file to keep the container running
exec tail -F /var/log/cron.log
