# Duplicacy Dockerfile
# Be sure to set End of Line sequence to LF
FROM debian:12

# Set critical environment variables
ENV DUPLICACY_PASSWORD=""
ENV B2_ID=""
ENV B2_KEY=""

# Set fixed environment variables
ENV CRON_DEFAULT_CONFIG=/duplicacy/cron-default.conf
ENV CRON_CONFIG=/duplicacy/appdata/cron/cron.conf
ENV LOG_BACKUP_FILE=/duplicacy/appdata/logs/duplicacy_backup.log
ENV LOG_PRUNE_FILE=/duplicacy/appdata/logs/duplicacy_prune.log

# Set timezone
ENV TZ=America/New_York

# Set working directory
WORKDIR /duplicacy

# Update and install dependencies
RUN apt update && \
    apt upgrade -y && \
    apt install -y bash cron wget procps vim

# Install duplicacy
RUN wget https://github.com/gilbertchen/duplicacy/releases/download/v3.2.3/duplicacy_linux_x64_3.2.3 -O /usr/local/bin/duplicacy && \
    chmod +x /usr/local/bin/duplicacy

# Create directories
RUN mkdir -p appdata/cron && \
    mkdir -p appdata/logs && \
    mkdir -p backup

# Set persistent volume path
VOLUME /duplicacy/appdata

# Copy files
COPY cron-default.conf .
COPY start.sh .

# Start script
CMD ["./start.sh"]
