#!/bin/bash

# Load Duplicacy environment variables
echo "# Load Duplicacy environment variables" > /root/.bashrc
while IFS='=' read -r key value
do
    echo "export $key=$value" >> /root/.bashrc
done < "$DUPLICACY_CONFIG"

# Create a new temporary crontab file
temp_cron_file="/tmp/crontab_with_env"

# Set the PATH for the cron jobs
echo "PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin" > $temp_cron_file

echo "" >> $temp_cron_file

# Append environment variables from duplicacy.conf to the temporary crontab file
cat $DUPLICACY_CONFIG >> $temp_cron_file

echo "" >> $temp_cron_file

# Append the original crontab entries to the temporary crontab file
cat $CRON_CONFIG >> $temp_cron_file

# Load the new crontab file
crontab $temp_cron_file

# Start cron
cron -f
