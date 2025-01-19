#!/bin/sh

source $HOME/.taskman/config

echo "email/username?"
read username

echo "password?"
read -s password

curl -X 'POST' "$AUTHURL/login" --data "{\"email\":\"$username\", \"password\":\"$password\"}" -v
