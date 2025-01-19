#!/bin/sh

source $HOME/.taskman/config

echo "name"
read name 

echo "cost"
read cost 

echo "priority"
read priority

echo "',' delimited categories ids (do not use category names for this)"
read categories 

curl -X 'POST' "$TASKURL/new" -H "Authorization: Bearer $TOKEN" --data "{\"name\":\"$name\", \"cost\":$cost, \"priority\":$priority, \"categories\": [$categories]}"