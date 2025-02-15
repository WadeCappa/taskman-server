#!/bin/sh

source $HOME/.taskman/config
echo "category id, category name, count"
curl -s -X 'GET' "$TASKURL/category" -H "Authorization: Bearer $TOKEN" | jq -r '.[] | [.category_id, .category_name, .count] | @csv'
