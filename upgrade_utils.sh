#!/bin/sh

get_time() {
	date --utc +"%A %D %T"
}

scale_to() {
    SERVICE_NAME=$1
    SCALE_TO_COUNT=$2
    docker compose up -d --no-deps --scale $SERVICE_NAME=$SCALE_TO_COUNT --no-recreate $SERVICE_NAME
    echo "$(get_time) scaled $SERVICE_NAME to $SCALE_TO_COUNT containers"
}

upgrade_service() {
    COMPOSE_FILE_NAME=$1
    DOCKER_NAME=$2
    # this should return true if the service is up, false otherwise
    HEALTH_CHECK_FUNC=$3

    git pull

    VERSION=$(git rev-parse HEAD)
    echo "$(get_time) deploying $COMPOSE_FILE_NAME version $VERSION"

    docker compose build
    echo "$(get_time) built version $VERSION"

    OLD_CONTAINER=$(docker ps -aqf "name=$DOCKER_NAME")
    echo "$(get_time) tracking old container of id $OLD_CONTAINER"

    scale_to $COMPOSE_FILE_NAME 2

    for i in $(seq 1 10); 
    do
        if [ $HEALTH_CHECK_FUNC ]; then 
            echo "$(get_time) healthcheck succeeded on attempt $i"
            break
        else
            echo "$(get_time) healthcheck failed attempt $i"
            sleep 3
        fi
    done

    docker stop $OLD_CONTAINER
    docker container rm -f $OLD_CONTAINER
    echo "$(get_time) stopped old container of id $OLD_CONTAINER"

    scale_to $COMPOSE_FILE_NAME 1

    echo "$(get_time) $COMPOSE_FILE_NAME version $VERSION has been deployed"
}
