#!/bin/sh

STATUS_CODE=$(curl -s -o /dev/null -w "%{http_code}" localhost:5501/check)

if [ $STATUS_CODE != 200 ] ; then 
    exit 1
else
    exit 0
fi