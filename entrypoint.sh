#!/bin/sh
set -e

# Write out the cron job
CRON_FILE=/etc/cron.d/myscript

# This will echo the date and a message, run the script, and log success or error
CMD="echo [$(date '+%Y-%m-%d %H:%M:%S')] Running $SCRIPT_PATH >> /var/log/cron.log; \
/bin/sh $SCRIPT_PATH >> /var/log/cron.log 2>&1; \
if [ $? -eq 0 ]; then \
  echo [$(date '+%Y-%m-%d %H:%M:%S')] $SCRIPT_PATH finished successfully >> /var/log/cron.log; \
else \
  echo [$(date '+%Y-%m-%d %H:%M:%S')] ERROR: $SCRIPT_PATH failed with exit code $? >> /var/log/cron.log; \
fi"
echo "$CRON_SCHEDULE root sh -c '$CMD'" > $CRON_FILE
chmod 0644 $CRON_FILE
crontab $CRON_FILE

# Ensure log file exists
mkdir -p /var/log
: > /var/log/cron.log

# Start cron in the background
cron

# Print next scheduled execution time and interval
if command -v cronnext >/dev/null 2>&1; then
  NEXT_RUN=$(cronnext "$CRON_SCHEDULE")
  INTERVAL=$(cronnext --interval "$CRON_SCHEDULE")
  echo "[INIT] Script will next be executed at: $NEXT_RUN (schedule: $CRON_SCHEDULE) and then every $INTERVAL"
else
  echo "[INIT] Script will be executed according to schedule: $CRON_SCHEDULE"
fi

# Tail the log file to keep the container running
exec tail -F /var/log/cron.log
