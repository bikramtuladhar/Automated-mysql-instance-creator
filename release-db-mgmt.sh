#!/bin/bash

# Ensure that script arguments are provided
if [ $# -lt 1 ]; then
    echo "Usage: $0 <volume_name> [port_number] [delete]"
    echo "./release-db-mgmt.sh jbv1-19133 19133"
    exit 1
fi

echo "$1";
echo "$2";
VOLUME_NAME=$1-volume
PORT_NUMBER=$2
CONTAINER_NAME=$1-$2-mysql-container

echo "Volume name: ${VOLUME_NAME}"
echo "container name: ${CONTAINER_NAME}"
echo "port: ${PORT_NUMBER}"

# Handle delete operation at the beginning
if [ "$3" = "delete" ]; then
    docker stop $CONTAINER_NAME && docker rm $CONTAINER_NAME && docker volume rm "jbv1-${PORT_NUMBER}-volume";
    exit 0
fi

# Ensure that port number is provided for non-delete operations
if [ $# -lt 2 ]; then
    echo "For non-delete operations, a port number must be provided."
    echo "Usage: $0 <volume_name> <port_number>"
    exit 1
fi

# Check if the volume exists, if not create and copy data to it
if ! docker volume inspect $VOLUME_NAME > /dev/null 2>&1; then
    docker volume create --name $VOLUME_NAME
    docker run --rm -v jobins_base_mysql_volume:/from -v $VOLUME_NAME:/to alpine ash -c 'cd /from ; cp -av . /to'
fi

# Check if the container exists by name and port number
if [ "$(docker ps -aq -f name=$CONTAINER_NAME)" ] || [ "$(docker ps -aq -f expose=$PORT_NUMBER)" ]; then
    # Get the current status of the container
    CONTAINER_STATUS=$(docker inspect --format='{{.State.Status}}' $CONTAINER_NAME)

    # Check if the container is in 'created' status
    if [ "$CONTAINER_STATUS" == "created" ]; then
        echo "Container $CONTAINER_NAME is created but not started."
        docker start $CONTAINER_NAME

    # Check if the container is stopped and created
    elif [ "$CONTAINER_STATUS" == "exited" ]; then
                # Get the exit code of the stopped container
                EXIT_CODE=$(docker inspect $CONTAINER_NAME --format='{{.State.ExitCode}}')
                if [ $EXIT_CODE -eq 0 ]; then
                    # Start the container if it exited with code 0
                    docker start $CONTAINER_NAME
                else
                    # Delete and recreate the container and volume if the exit code is non-zero
                    docker rm $CONTAINER_NAME
                    docker volume rm $VOLUME_NAME
                    docker volume create --name $VOLUME_NAME
                    docker run --rm -v jobins_base_mysql_volume:/from -v $VOLUME_NAME:/to alpine ash -c 'cd /from ; cp -av . /to'
                    docker run -d --name $CONTAINER_NAME -v $VOLUME_NAME:/var/lib/mysql -p $PORT_NUMBER:3306 --restart unless-stopped mysql:8.0.37 --character-set-server=utf8mb4 --collation-server=utf8mb4_unicode_ci --binlog-expire-logs-auto-purge={ON}
                fi

    else
        echo "Container $CONTAINER_NAME is already running."
    fi
else
    # Start the container in detached mode if it does not exist
    docker run -d --name $CONTAINER_NAME -v $VOLUME_NAME:/var/lib/mysql -p $PORT_NUMBER:3306 --cpus=2 --memory=4g --restart unless-stopped mysql:8.0.37 --character-set-server=utf8mb4 --collation-server=utf8mb4_unicode_ci --binlog-expire-logs-auto-purge={ON}
fi