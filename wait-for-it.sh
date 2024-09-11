#!/bin/bash

# Ensure that container name is provided
if [ $# -lt 1 ]; then
    echo "Usage: $0 <container_name> [port]"
    exit 1
fi

CHECK_PORT=$2
CONTAINER_NAME=$1-$CHECK_PORT-mysql-container
TIMEOUT=120 # 2 minutes in seconds
START_TIME=$(date +%s)

# Function to check if container is running
is_container_running() {
    [ "$(docker inspect -f '{{.State.Running}}' $CONTAINER_NAME 2> /dev/null)" = "true" ]
}

# Function to check if port is open (optional)
is_port_open() {
    nc -z 192.168.11.153 $CHECK_PORT
}

# Function to check if the timeout is reached
is_timeout_reached() {
    CURRENT_TIME=$(date +%s)
    [ $((CURRENT_TIME - START_TIME)) -ge $TIMEOUT ]
}

# Wait for container to run
until is_container_running || is_timeout_reached; do
    echo "Waiting for container $CONTAINER_NAME to be up..."
    sleep 1
done

if is_timeout_reached; then
    echo "Timeout reached while waiting for container $CONTAINER_NAME."
    exit 1
fi

echo "Container $CONTAINER_NAME is up."

# If port number is provided, also check if the port is open
if [ ! -z "$CHECK_PORT" ]; then
    until is_port_open || is_timeout_reached; do
        echo "Waiting for port $CHECK_PORT to be open..."
        sleep 10
    done

    if is_timeout_reached; then
        echo "Timeout reached while waiting for port $CHECK_PORT."
        exit 1
    fi

    echo "Port $CHECK_PORT is open."
fi

sleep 10

echo "Container $CONTAINER_NAME is available."
