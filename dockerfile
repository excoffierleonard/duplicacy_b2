FROM debian:12

WORKDIR /duplicacy

ENV TZ=America/New_York
ENV DUPLICACY_CONFIG=/duplicacy/appdata/duplicacy/duplicacy.conf
ENV CRON_CONFIG=/duplicacy/appdata/cron/cron.conf

RUN apt-get update && \
    apt-get install -y cron wget procps vim && \
    wget https://github.com/gilbertchen/duplicacy/releases/download/v3.2.3/duplicacy_linux_x64_3.2.3 -O /usr/local/bin/duplicacy && \
    chmod +x /usr/local/bin/duplicacy && \
    rm -rf /var/lib/apt/lists/*

RUN mkdir -p /duplicacy/appdata/duplicacy && \
    mkdir -p /duplicacy/appdata/cron && \
    mkdir -p /duplicacy/appdata/logs && \
    mkdir -p /backupsource

COPY start.sh .

CMD ["./start.sh"]
