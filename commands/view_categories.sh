#!/bin/sh

source $HOME/.taskman/config
curl -X 'GET' "$TASKURL/category" -H "Authorization: Bearer $TOKEN"
