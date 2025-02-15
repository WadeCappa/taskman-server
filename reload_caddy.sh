#!/bin/sh

source upgrade_utils.sh

CADDY_CONTAINER=docker ps -aqf "name=caddy"
echo "$(get_time) reloading caddy container $CADDY_CONTAINER"
docker exec $CADDY_CONTAINER caddy reload -c /etc/caddy/Caddyfile