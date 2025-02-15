#!/bin/sh

source $HOME/.taskman/config

RES=$(curl -sw "%{http_code}" "$TASKURL/category/$1" -H "Authorization: Bearer $TOKEN")

STATUS_CODE=$(echo "$RES" | jq | tail -n1)

CONTENT=${RES::-3}
if [ $STATUS_CODE != 200 ] ; then 
    echo "status code of $STATUS_CODE"
    echo "$CONTENT" | jq
else
    echo "[category id, category name, count]"
    echo "$CONTENT" | jq -c '.[] | [.category_id, .category_name, .count]'
fi
