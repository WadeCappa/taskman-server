#!/bin/sh

source $PWD/upgrade_utils.sh

taskman_ready() {
    docker exec -it $(docker ps -aqf "name=taskman-server-taskman") bash healthcheck.sh
}

upgrade_service "taskman" "taskman-server-taskman" taskman_ready