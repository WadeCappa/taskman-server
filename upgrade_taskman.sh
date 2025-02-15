#!/bin/sh

git pull

get_time() {
	date --utc +"%A %D %T"
}

VERSION=$(git rev-parse HEAD)
echo "$(get_time) deploying taskman version $VERSION"

docker compose build
echo "$(get_time) built version $VERSION"

OLD_CONTAINER=$(docker ps -aqf "name=taskman-server-taskman")
echo "$(get_time) tracking old container of id $OLD_CONTAINER"

docker compose up -d --scale taskman=2 --no-recreate taskman
echo "$(get_time) scaled up containers"

sleep 60

docker stop $OLD_CONTAINER
echo "$(get_time) stopped old container of id $OLD_CONTAINER"
docker container rm -f $OLD_CONTAINER
docker compose up -d --scale taskman=1 --no-recreate taskman
echo "$(get_time) scaled back down to one container"

echo "$(get_time) taskman version $VERSION has been deployed"
