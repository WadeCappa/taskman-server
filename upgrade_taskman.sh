#!/bin/sh

source $PWD/upgrade_utils.sh

taskman_ready() {
    SUCCESS_COND="success"
    FAILURE_COND="failure"
    CONTAINERS=$(docker ps -aqf "name=taskman-server-taskman")
    echo "looking at $CONTAINERS"
    for C in $CONTAINERS; do
        STATUS=$((docker exec $C bash healthcheck.sh && echo $SUCCESS_COND) || echo $FAILURE_COND)
        echo "container $C has status of $STATUS"
        if [ "$STATUS" != $SUCCESS_COND ]; then 
            echo "failed check for $C"
            return 1
        fi
    done
    echo "all checks passing"
    return 0
}

upgrade_service "taskman" "taskman-server-taskman" taskman_ready