#!/bin/sh

source /etc/opt/taskman/config
curl -X 'PUT' "$TASKURL/set/$1/$2" -H "Authorization: Bearer $TOKEN" 
