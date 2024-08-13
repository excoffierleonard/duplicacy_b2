# Duplicacy Dockerfile
FROM debian:12

# Set required environment variables
ENV DUPLICACY_PASSWORD=""
ENV DUPLICACY_B2_ID=""
ENV DUPLICACY_B2_KEY=""
ENV SNAPSHOT_ID=""
ENV B2_URL=""

# Set optional environment variables
ENV THREADS=1
ENV TZ=America/New_York

# Set fixed environment variables
ENV BACKUP_DIR=/duplicacy/backup
ENV APPDATA_DIR=/duplicacy/appdata

ENV CRON_DIR=/duplicacy/appdata/cron
ENV LOG_DIR=/duplicacy/appdata/logs

ENV CRON_DEFAULT_CONFIG=/duplicacy/cron-default.conf
ENV CRON_CONFIG=/duplicacy/appdata/cron/cron.conf
ENV LOG_BACKUP_FILE=/duplicacy/appdata/logs/duplicacy_backup.log
ENV LOG_PRUNE_FILE=/duplicacy/appdata/logs/duplicacy_prune.log

# Set working directory
WORKDIR /duplicacy

# Update and install dependencies
RUN apt update && \
    apt upgrade -y && \
    apt install -y bash cron wget procps vim

# Install duplicacy
RUN wget https://github.com/gilbertchen/duplicacy/releases/download/v3.2.3/duplicacy_linux_x64_3.2.3 -O /usr/local/bin/duplicacy && \
    chmod +x /usr/local/bin/duplicacy

# Create root directories
RUN mkdir -p /duplicacy/backup && \
    mkdir -p /duplicacy/appdata

# Set persistent volume path
VOLUME /duplicacy/appdata

# Copy files
COPY cron-default.conf .
COPY start.sh .

# Start script
CMD ["./start.sh"]
