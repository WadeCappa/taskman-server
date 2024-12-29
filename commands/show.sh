#!/bin/sh

source ~/Projects/taskman-server/commands/config
curl -X 'GET' "$TASKURL/show/$1" -H "Authorization: Bearer $TOKEN" 