#!/bin/sh

source $HOME/.taskman/config


echo "category id, category name, count"

RES=$(curl -sw "%{http_code}" "$TASKURL/category/$1" -H "Authorization: Bearer $TOKEN")

STATUS_CODE=$(echo "$RES" | jq | tail -n1)

CONTENT=${RES::-3}
if [ $STATUS_CODE != 200 ] ; then 
    echo "status code of $STATUS_CODE"
    echo "$CONTENT" | jq
else
    echo "$CONTENT" | jq -r '.[] | [.category_id, .category_name, .count] | @csv'
fi
