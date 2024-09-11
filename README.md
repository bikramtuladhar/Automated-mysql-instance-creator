# MySQL Volume Management and Release Automation Scripts

This project contains a set of shell scripts and Docker configuration files for managing MySQL container volumes and automating release processes.

## Prerequisites

- **Docker**: Ensure Docker is installed and running on your system.
- **Percona XtraBackup**: Used for MySQL backups.
- **Alpine**: Used for copying files between Docker volumes.
- **Shell2HTTP**: A lightweight tool to run shell scripts over HTTP.

---

## Script Descriptions

### 1. `mysql_volume_upgrade.sh`

This script creates a backup of an existing MySQL volume using Percona XtraBackup and copies the data to a new Docker volume.

#### Steps:

1. **Remove existing temporary volume**: The script removes any existing temporary volume (`jobins_base_mysql_volume_temp`).
2. **Backup MySQL data**: Using Percona XtraBackup, it backs up MySQL data from a container (`mysql_8`) to the new volume.
3. **Copy Data**: The data is copied to a new volume (`jobins_base_mysql_volume`).

#### Usage:
```bash
./mysql_volume_upgrade.sh
```

---

### 2. `purge_mysql_logs.sh`

This script purges binary logs for running MySQL containers based on the image version `mysql:8.0.37`.

#### Steps:

1. **Find container IDs**: Retrieves container IDs running MySQL 8.0.37.
2. **Purge logs**: Executes the `PURGE BINARY LOGS` command inside each container.

#### Usage:
```bash
./purge_mysql_logs.sh
```

---

### 3. `release-db-mgmt.sh`

This script handles the management of MySQL container volumes for specific releases.

#### Steps:

- **Create/Copy Volume**: Creates a Docker volume and copies data from the base volume (`jobins_base_mysql_volume`).
- **Start/Stop Container**: Starts or removes MySQL containers based on volume and port configurations.
- **Delete Option**: You can pass `delete` as an argument to stop, remove, and delete the volume for a specific release.

#### Usage:
```bash
./release-db-mgmt.sh <volume_name> <port_number> [delete]
```
Example:
```bash
./release-db-mgmt.sh jbv1-19133 19133
./release-db-mgmt.sh jbv1-19133 19133 delete
```

---

### 4. `shell2http.dockerfile`

This Dockerfile builds an environment with `shell2http`, allowing the execution of shell scripts over HTTP. It also installs Docker CLI to manage containers within the Docker image.

#### Key Features:

- **Installs Docker CLI**.
- **Installs Shell2HTTP** for HTTP requests on port 8081.
- **Runs management scripts** for container and volume operations.

---

### 5. `wait-for-it.sh`

This script waits for a Docker container to start and optionally checks if a specific port is open.

#### Steps:

1. **Wait for Container**: Continuously checks if the container is running.
2. **Check Port (Optional)**: If a port is provided, it waits for the port to be available.

#### Usage:
```bash
./wait-for-it.sh <container_name> [port]
```
Example:
```bash
./wait-for-it.sh jbv1 19133
```

---

## Docker Usage

To build and run the Shell2HTTP Docker container:

1. **Build the Docker image**:
    ```bash
    docker build -t shell2http-image -f shell2http.dockerfile .
    ```

2. **Run the container**:
    ```bash
    docker run -d -p 8081:8081 shell2http-image
    ```

This will expose port `8081` for HTTP requests to run the management scripts.

---

## License

This project is licensed under the MIT License. See [LICENSE](LICENSE) for details.
