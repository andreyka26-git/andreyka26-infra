#!/bin/bash

# Define the path to your Docker Compose file
DOCKER_COMPOSE_FILE="/services/nginx/docker-compose.yml"

# Renew all certificates using the specified Docker Compose file
output=$(/usr/local/bin/docker-compose -f $DOCKER_COMPOSE_FILE run --rm certbot renew --force-renewal 2>&1)

# Check if the command was successful
if [ $? -eq 0 ]; then
  /services/backup/send-to-telegram.sh "Certificates renewed successfully. Output: $output"

  if [ $? -eq 0 ]; then
    # Restart Nginx service
    restart_output=$(cd /services/nginx && /usr/local/bin/docker-compose restart 2>&1)

    /services/backup/send-to-telegram.sh "Nginx restarted successfully. Output: $restart_output"
  else
    /services/backup/send-to-telegram.sh "Failed to restart Nginx. Error: $restart_output"
  fi
else
  /services/backup/send-to-telegram.sh "Failed to renew certificates. Error: $output"
fi

# Output the result to the console as well
echo "$output"
echo "$restart_output"