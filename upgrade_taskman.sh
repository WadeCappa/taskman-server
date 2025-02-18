#!/bin/sh

source $PWD/upgrade_utils.sh

taskman_ready() {
    CONTAINER=$1

    SUCCESS_COND="success"
    FAILURE_COND="failure"

    echo "looking at $CONTAINER"
    STATUS=$((docker exec $CONTAINER bash healthcheck.sh && echo $SUCCESS_COND) || echo $FAILURE_COND)
    echo "container $CONTAINER has status of $STATUS"
    if [ "$STATUS" != $SUCCESS_COND ]; then 
        echo "failed check for $CONTAINER"
        return 1
    fi

    echo "all checks passing for container $CONTAINER"
    return 0
}

upgrade_service "taskman" "taskman-server-taskman" taskman_ready