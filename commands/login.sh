#!/bin/sh

echo "email/username?"
read username

echo "password?"
read -s password

source /etc/opt/taskman/config

curl -X 'POST' "$AUTHURL/login" --data "{\"email\":\"$username\", \"password\":\"$password\"}" -v
