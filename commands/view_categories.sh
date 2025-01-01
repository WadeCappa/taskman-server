#!/bin/sh

source /etc/opt/taskman/config
curl -X 'GET' "$TASKURL/category" -H "Authorization: Bearer $TOKEN"
