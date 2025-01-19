#!/bin/sh

source $HOME/.taskman/config
curl -X 'GET' "$TASKURL/describe/$1" -H "Authorization: Bearer $TOKEN" 