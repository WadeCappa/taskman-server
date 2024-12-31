#!/bin/sh

source /etc/opt/taskman/config
curl -X 'GET' "$TASKURL/describe/$1" -H "Authorization: Bearer $TOKEN" 