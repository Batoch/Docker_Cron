#!/bin/sh
set -e

# Write out the cron job
CRON_FILE=/etc/cron.d/myscript

# This will echo the date and a message, run the script, and log success or error
CMD="echo [\\\$(date '+%Y-%m-%d %H:%M:%S')] Running $SCRIPT_PATH | tee -a /var/log/cron.log; \
if /bin/bash $SCRIPT_PATH 2>&1 | tee -a /var/log/cron.log; then \
  echo [\\\$(date '+%Y-%m-%d %H:%M:%S')] $SCRIPT_PATH finished successfully | tee -a /var/log/cron.log; \
else \
  echo [\\\$(date '+%Y-%m-%d %H:%M:%S')] ERROR: $SCRIPT_PATH failed with exit code \\\$? | tee -a /var/log/cron.log; \
fi"
echo "$CRON_SCHEDULE root bash -c '$CMD'" > $CRON_FILE
chmod 0644 $CRON_FILE
# crontab $CRON_FILE

# Ensure log file exists
mkdir -p /var/log
: > /var/log/cron.log

# Optionally run the script once after init if RUN_ON_START is set to 'true'
if [ "${RUN_ON_START:-false}" = "true" ]; then
  echo "[INIT] RUN_ON_START is true, running $SCRIPT_PATH immediately..."
  echo "[INIT] --- Immediate run start ---"
  echo [$(date '+%Y-%m-%d %H:%M:%S')] Running $SCRIPT_PATH | tee -a /var/log/cron.log
  if /bin/bash $SCRIPT_PATH 2>&1 | tee -a /var/log/cron.log; then
    echo [$(date '+%Y-%m-%d %H:%M:%S')] $SCRIPT_PATH finished successfully | tee -a /var/log/cron.log
  else
    echo [$(date '+%Y-%m-%d %H:%M:%S')] ERROR: $SCRIPT_PATH failed with exit code $? | tee -a /var/log/cron.log
  fi
  echo "[INIT] --- Immediate run end ---"
fi

# Start cron in the background
cron

# Print next scheduled execution time and interval
if python3 -c "import croniter" 2>/dev/null; then
  NEXT_RUN=$(python3 -c "from croniter import croniter; from datetime import datetime; it = croniter('$CRON_SCHEDULE', datetime.now()); print(it.get_next(datetime).strftime('%Y-%m-%d %H:%M:%S'))")
  INTERVAL=$(python3 -c "from croniter import croniter; from datetime import datetime; it = croniter('$CRON_SCHEDULE', datetime.now()); n1 = it.get_next(datetime); n2 = it.get_next(datetime); print(str(n2-n1))")
  echo "[INIT] Script will next be executed at: $NEXT_RUN (schedule: $CRON_SCHEDULE) and then every $INTERVAL"
else
  echo "[INIT] Script will be executed according to schedule: $CRON_SCHEDULE"
fi

# Tail the log file to keep the container running
exec tail -F /var/log/cron.log
