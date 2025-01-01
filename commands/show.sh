#!/bin/sh

source /etc/opt/taskman/config
curl -X 'GET' "$TASKURL/show/$1/$2" -H "Authorization: Bearer $TOKEN" 
