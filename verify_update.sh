#!/bin/bash
LOG_FILE_PATH="/var/www/html/services/update-toolbox/app.log"
DATE=$(date +"%Y/%m/%d")
echo -n > $LOG_FILE_PATH
echo "Log file emptied."
sleep 30
if [[ "$FIRST_LOG_ENTRY" != *"$DATE"* || "$FIRST_LOG_ENTRY" != *"Started"* ]]; then
  echo "The first log entry is not from today or does not start with 'Started'"
  exit 1
else
  echo "First log entry is valid."
fi

sleep 180
LAST_LOG_ENTRY=$(tail -n 1 $LOG_FILE_PATH)

if [[ "$LAST_LOG_ENTRY" == *"$DATE"* && "$LAST_LOG_ENTRY" == *"Completed Update"* ]]; then
  echo "Update completed successfully."
else
  echo "Update did not complete successfully. Last log entry: $LAST_LOG_ENTRY"
  exit 1
fi
