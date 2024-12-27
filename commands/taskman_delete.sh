#!/bin/sh

source ~/Projects/taskman-server/commands/config
curl -X 'PUT' "$TASKURL/delete/$1" -H "Authorization: Bearer $TOKEN" 