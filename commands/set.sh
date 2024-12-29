#!/bin/sh

source ~/Projects/taskman-server/commands/config
curl -X 'PUT' "$TASKURL/set/$1/$2" -H "Authorization: Bearer $TOKEN" 