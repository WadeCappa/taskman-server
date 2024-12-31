#!/bin/sh

source /etc/opt/taskman/config

echo "name"
read name 

echo "cost"
read cost 

echo "priority"
read priority

curl -X 'POST' "$TASKURL/new" -H "Authorization: Bearer $TOKEN" --data "{\"name\":\"$name\", \"cost\":$cost, \"priority\":$priority}" 
