#!/bin/sh

source /etc/opt/taskman/config
curl -X 'PUT' "$TASKURL/delete/$1" -H "Authorization: Bearer $TOKEN" 
