#!/bin/sh

echo "email/username?"
read username

echo "password?"
read -s password

source ~/Projects/taskman-server/commands/config

curl -X 'POST' "$AUTHURL/new" --data "{\"email\":\"$username\", \"password\":\"$password\"}" -v