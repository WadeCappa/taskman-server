#!/bin/sh

source /etc/opt/taskman/config

echo "category name"
read name 

curl -X 'POST' "$TASKURL/category" -H "Authorization: Bearer $TOKEN" --data "{\"name\":\"$name\"}"