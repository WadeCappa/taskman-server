#!/bin/sh

source $HOME/.taskman/config

echo "comment"
read comment

curl -X 'POST' "$TASKURL/comment/$1" -H "Authorization: Bearer $TOKEN" --data "{\"content\":\"$comment\"}" 
