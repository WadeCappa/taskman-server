#!/bin/sh

source $PWD/upgrade_utils.sh

# no health check yet, just sleep
authman_ready() {
    sleep 60
    return 0
}

upgrade_service "authman" "taskman-server-authman" authman_ready