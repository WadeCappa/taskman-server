#!/bin/sh

get_time() {
	date --utc +"%A %D %T"
}

scale_to() {
    SERVICE_NAME=$1
    SCALE_TO_COUNT=$2
    docker compose up -d --no-deps --scale $SERVICE_NAME=$SCALE_TO_COUNT --no-recreate $SERVICE_NAME
}

wait_for_upgrade() {
    HEALTH_CHECK_FUNC=$1
    NEW_CONTAINER=$2
    for i in $(seq 1 10);
    do
        if $HEALTH_CHECK_FUNC $NEW_CONTAINER; then 
            echo "$(get_time) healthcheck succeeded on attempt $i"
            return 0
        else
            echo "$(get_time) healthcheck failed attempt $i"
            sleep 3
        fi
    done
    return 1
}

get_running_containers() {
    DOCKER_NAME=$1
    echo "$(docker ps -qf "name=$DOCKER_NAME")"
}

get_new_container() {
    PREVIOUS_CONTAINERS=$1
    NEW_CONTAINERS=$2
    for n in "${NEW_CONTAINERS[@]}"
    do
        FOUND=0
        for p in "${PREVIOUS_CONTAINERS[@]}"
        do
            if [ "$n" = $p ]; then 
                FOUND=1
                break
            fi
        done
        if [ "$FOUND" = 0 ]; then
            echo "$n"
            return 0
        fi
    done

    echo "failed to find new container"
    return 1
}

upgrade_service() {
    COMPOSE_FILE_NAME=$1
    DOCKER_NAME=$2
    # this should return true if the service is up, false otherwise
    HEALTH_CHECK_FUNC=$3

    git pull

    VERSION=$(git rev-parse HEAD)
    echo "$(get_time) deploying $COMPOSE_FILE_NAME version $VERSION"

    # docker compose build
    echo "$(get_time) built version $VERSION"

    OLD_CONTAINERS=($(get_running_containers $DOCKER_NAME))
    echo $OLD_CONTAINERS
    DESIRED_CONTAINERS=${#OLD_CONTAINERS[@]}
    SCALE_CONTAINER_NUMBER=$DESIRED_CONTAINERS

    UPGRADED_CONTAINERS=()

    for OLD_CONTAINER in "${OLD_CONTAINERS[@]}"
    do
        echo "$(get_time) tracking old container of id $OLD_CONTAINER"

        # increment total number of containers 
        SCALE_CONTAINER_NUMBER=$(($SCALE_CONTAINER_NUMBER + 1))

        PREVIOUS_CONTAINERS=($(get_running_containers $DOCKER_NAME))
        scale_to $COMPOSE_FILE_NAME $SCALE_CONTAINER_NUMBER
        NEW_CONTAINERS=($(get_running_containers $DOCKER_NAME))

        NEW_CONTAINER=$(get_new_container $PREVIOUS_CONTAINERS, $NEW_CONTAINERS)
        echo "$(get_time) scaled up to ${#NEW_CONTAINERS[@]} containers with new container of $NEW_CONTAINER"

        if ! wait_for_upgrade $HEALTH_CHECK_FUNC $NEW_CONTAINER; then 
            echo "$(get_time) failed upgrade, rolling back"
            for C in "${OLD_CONTAINERS[@]}"
            do
                docker start $C
            done
            for C in "${UPGRADED_CONTAINERS[@]}"
            do
                docker stop $C
                docker container rm -f $OLD_CONTAINER
            done
            scale_to $COMPOSE_FILE_NAME $DESIRED_CONTAINERS
            return 1
        fi

        UPGRADED_CONTAINERS+=($NEW_CONTAINER)
    done

    for OLD_CONTAINER in "${OLD_CONTAINERS[@]}"
    do
        docker container rm -f $OLD_CONTAINER
    done
    scale_to $COMPOSE_FILE_NAME $DESIRED_CONTAINERS

    echo "$(get_time) $COMPOSE_FILE_NAME version $VERSION has been deployed"
    return 0
}
