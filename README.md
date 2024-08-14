# Duplicacy B2 Docker Project

This Docker project is designed to simplify the setup and management of backups using Duplicacy with Backblaze B2 cloud storage. By using Docker, the project encapsulates all dependencies and configurations neatly, ensuring a consistent and reproducible environment for your backup operations.

## Table of Contents
1. [Sources](#sources)
2. [Project Structure](#project-structure)
3. [Environment Variables](#environment-variables)
4. [Usage](#usage)
5. [Default Cron Configuration](#default-cron-configuration)
6. [Logs](#logs)
7. [Commands](#commands)
8. [Building Locally](#building-locally)
9. [Notes](#notes)
10. [License](#license)


## Sources

 - This project uses the command line version of [Duplicacy](https://github.com/gilbertchen/duplicacy).
 - You can find the source code of this project on [GitHub](https://github.com/excoffierleonard/docker-duplicacy_b2).
 - You can find the Docker image of this project on [Docker Hub](https://hub.docker.com/r/excoffierleonard/duplicacy_b2).

 - This project requires [Docker Engine](https://docs.docker.com/engine/install/) and a [Backblaze B2](https://www.backblaze.com/cloud-storage) account.

## Project Structure

- `Dockerfile`: Defines the Docker image, including dependencies and configuration.
- `start.sh`: Script to initialize and set up the environment for Duplicacy.
- `cron-default.conf`: Default cron job configurations for backup and pruning operations.
- `compose.yaml`: Docker Compose file to define and manage the container.
- `.dockerignore`: List of files and directories to be ignored by Docker during build.
- `.gitignore`: Specifies files to be ignored by Git.

## Environment Variables

The following environment variables can be set either in a `.env` file, directly written in `compose.yaml`, or hardcoded in the `Run` command:

### Required:

- `DUPLICACY_PASSWORD`: Your backup password.
- `DUPLICACY_B2_ID`: Your Backblaze B2 application ID.
- `DUPLICACY_B2_KEY`: Your Backblaze B2 application key.
- `SNAPSHOT_ID`: The name of your snapshot.
- `B2_URL`: Your Backblaze Bucket URL.

### Optional:

- `THREADS`: Number of threads for backup operations. (Default is 1)
- `TZ`: Timezone for the container. (Default is America/New_York)
- `BACKUP_PATH_1`: Path to the folder you want to back up.
- `BACKUP_FOLDER_NAME_1`: How the backup folder will be named in the backup.

> In the case where you use an `.env` and you wish to not use the `THREADS` or `TZ` environment variable: you must delete their lines from (or simply not include them in) the `compose.yaml`.

## Usage

### Prerequisites

1. **Docker Engine**

  - Install [Docker Engine](https://docs.docker.com/engine/install/).

2. **Backblaze**

  - Create a [Backblaze B2](https://www.backblaze.com/cloud-storage) account.

  - Create a [B2 Cloud Storage Bucket](https://secure.backblaze.com/b2_buckets.htm).

  - Generate an [Application Key](https://secure.backblaze.com/app_keys.htm) that has Read and Write Access to the [B2 Cloud Storage Bucket](https://secure.backblaze.com/b2_buckets.htm) created.

    - Save the `KeyID` (DUPLICACY_B2_ID) and `applicationKey` (DUPLICACY_B2_KEY) somewhere safe.

### Preferred Method: Using Docker Compose

Docker Compose simplifies managing and running your container setups. Please ensure Docker and Docker Compose are installed on your system. You can find installation instructions here: [Docker Install Instructions](https://docs.docker.com/get-docker/), [Docker Compose Install Instructions](https://docs.docker.com/compose/install/).

#### Steps:

1. **Create a `compose.yaml` File:**
    
    Create a `compose.yaml` file with the following content, you can find a template in the repo [here](compose.yaml).

    ```yaml
    services:
      duplicacy_b2:
        image: excoffierleonard/duplicacy_b2
        container_name: duplicacy_b2
        environment:
          DUPLICACY_PASSWORD: ${DUPLICACY_PASSWORD} # Enter your backup password here
          DUPLICACY_B2_ID: ${DUPLICACY_B2_ID} # Enter your Backblaze id here
          DUPLICACY_B2_KEY: ${DUPLICACY_B2_KEY} # Enter your Backblaze key here
          SNAPSHOT_ID: ${SNAPSHOT_ID} # Enter the name of your snapshot here
          B2_URL: ${B2_URL} # Enter your Backblaze Bucket URL here
          THREADS: ${THREADS} # Enter the number of threads you want to use for the backup
          TZ: ${TZ} # Enter your timezone here
        volumes:
          - duplicacy_b2:/duplicacy/appdata # Docker volume for duplicacy_b2 appdata
          - ${BACKUP_PATH_1}:/duplicacy/backup/${BACKUP_FOLDER_NAME_1} # Enter the path to the folder(s) you want to backup here, add more lines if you want to backup multiple folders
        networks:
          - duplicacy_b2 # Image specific Docker network for isolation

    volumes:
      duplicacy_b2:
        name: duplicacy_b2

    networks:
      duplicacy_b2:
        name: duplicacy_b2
    ```

2. **Create a `.env` File:**

   Set up environment variables by creating a `.env` file in the same directory as `compose.yaml`. You can use the example below as a guideline:

   ```
   DUPLICACY_PASSWORD=your_backup_password
   DUPLICACY_B2_ID=your_b2_id
   DUPLICACY_B2_KEY=your_b2_key
   SNAPSHOT_ID=your_snapshot_id
   B2_URL=your_b2_bucket_url
   THREADS=1
   TZ=America/New_York
   BACKUP_PATH_1=/path/of/folder/to/backup
   BACKUP_FOLDER_NAME_1=/name/of/folder
   ```

   Alternatively, you can hardcode these values directly in `compose.yaml`.

4. **Launch the Service:**

   - Start the containers in detached mode with Docker Compose:
     ```sh
     docker compose up -d
     ```

### Alternative Method: Using Docker `Run`

For users who prefer the direct Docker command or have specific use cases, Docker Run can also be used.

1. **Create a Docker Network:**

   This step ensures proper container communication and isolation:

   ```sh
   docker network create duplicacy_b2
   ```

2. **Execute the `Run` command:**

   Run the Docker container with your defined network and replace placeholders with actual values:

   ```sh
   docker run \
     -d \
     --name duplicacy_b2 \
     --net=duplicacy_b2 \
     -e DUPLICACY_PASSWORD=<your_backup_password> \
     -e DUPLICACY_B2_ID=<your_b2_id> \
     -e DUPLICACY_B2_KEY=<your_b2_key> \
     -e SNAPSHOT_ID=<your_snapshot_id> \
     -e B2_URL=<your_b2_bucket_url> \
     -e THREADS=1 \
     -e TZ=America/New_York \
     -v duplicacy_b2:/duplicacy/appdata \
     -v BACKUP_PATH_1:/duplicacy/backup/BACKUP_FOLDER_NAME_1 \
     excoffierleonard/duplicacy_b2
   ```

## Default Cron Configuration

The container comes with a default cron configuration file (`cron-default.conf`), which sets up daily backup and pruning schedules:

- **Backup Job:** Runs daily at 3 AM.
- **Prune Job:** Runs daily at 4 AM. The default pruning schedule retains daily backups for the first week, weekly backups past 7 days, monthly backups beyond 30 days, and annual backups after 360 days
- **Log Rotation:** Rotates logs every 7 days at 2 AM.

To customize these schedules or add new cron jobs, modify the cron configuration file located in your Docker volume at `duplicacy_b2/cron/cron.conf`. Doing so will ensure your changes are preserved across container restarts.

## Logs

The backup and prune log files can be found in the Docker volume at `duplicacy_b2/logs/`. Specifically, the backup log is `duplicacy_backup.log` and the prune log is `duplicacy_prune.log`.

## Commands

- **View Logs:**

  To view the backup and prune logs, use:

  ```
  docker logs duplicacy_b2
  ```

- **Stop the Service:**

  To stop the service, use:

  ```
  docker compose down
  ```

  or if using the run command:

  ```
  docker container stop duplicacy_b2
  ```

## Building Locally

   ```
   git clone https://github.com/yourusername/docker-duplicacy_b2.git
   cd docker-duplicacy_b2
   docker build -t duplicacy_b2 .
   ```

   - Dont't forget to modify the image name in the `compose.yaml` or `Run` command accordingly.

## Notes

- The usage steps include the creation of a separate docker network, we chose this option because this Docker container will likely have access to sensitive files, the separate docker network provides additional isolation.

- The appdata folder is by default linked to a Docker Volume for persistency ease of management.

- Make sure to corretly bind the folders you want backed-up as subdirectories of `/duplicacy/backup` (it is set that way by default), this has two purposes: 1, it isolates the `.duplicacy` from the host filesystem, 2, it shows the name of the backed-up directory when inspecting the backup.

## License

This project is licensed under the [MIT License](LICENSE). Feel free to use and modify it as needed.
