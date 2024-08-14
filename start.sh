#!/bin/bash

# Exit if the some environment variables are not set
: ${DUPLICACY_PASSWORD:?"Environment variable DUPLICACY_PASSWORD is required but not set."}
: ${DUPLICACY_B2_ID:?"Environment variable B2_ID is required but not set."}
: ${DUPLICACY_B2_KEY:?"Environment variable B2_KEY is required but not set."}
: ${SNAPSHOT_ID:?"Environment variable SNAPSHOT_ID is required but not set."}
: ${B2_URL:?"Environment variable B2_URL is required but not set."}
: ${THREADS:?"Environment variable THREADS is required but not set."}
: ${TZ:?"Environment variable TZ is required but not set."}

# Create necessary directories
mkdir -p $CRON_DIR
mkdir -p $LOG_DIR

# Duplicacy init
cd $BACKUP_DIR && duplicacy init -e $SNAPSHOT_ID $B2_URL

# Create default configuration file if not exists
if [ ! -f "$CRON_CONFIG" ]; then
    echo "Creating default cron.conf"
    if [ -f "$CRON_DEFAULT_CONFIG" ]; then
        cp "$CRON_DEFAULT_CONFIG" "$CRON_CONFIG"
    else
        echo "Default cron file not found."
        exit 1
    fi
fi

# Create a new temporary crontab file
temp_cron_file="/tmp/crontab_with_envs"

# Append the environment variables to the temp cron configuration file
echo "PATH=$PATH" > $temp_cron_file
echo "DUPLICACY_PASSWORD=$DUPLICACY_PASSWORD" >> $temp_cron_file
echo "DUPLICACY_B2_ID=$DUPLICACY_B2_ID" >> $temp_cron_file
echo "DUPLICACY_B2_KEY=$DUPLICACY_B2_KEY" >> $temp_cron_file
echo "THREADS=$THREADS" >> $temp_cron_file
echo "LOG_BACKUP_FILE=$LOG_BACKUP_FILE" >> $temp_cron_file
echo "LOG_PRUNE_FILE=$LOG_PRUNE_FILE" >> $temp_cron_file

# Append the cron configuration to the temp cron configuration file
cat $CRON_CONFIG >> $temp_cron_file

# Load the new crontab file
crontab $temp_cron_file

# Start cron
cron

# Ensure log files exist to avoid tail errors
touch "$LOG_BACKUP_FILE" "$LOG_PRUNE_FILE"

# Monitor the logs
tail -f "$LOG_BACKUP_FILE" "$LOG_PRUNE_FILE"
