#!/bin/bash

# Get the list of container IDs running mysql:8.0.37
container_ids=$(docker ps --filter ancestor=mysql:8.0.37 --format "{{.ID}}")

# Loop through each container ID
for container_id in $container_ids; do
  echo "Purging binary logs for container ID: $container_id"
  docker exec -it $container_id mysql -uroot -ppassword -e "PURGE BINARY LOGS BEFORE NOW();"
done