#!/bin/bash

TEMP=`getopt -o m:u:i::c: -- "$@"`
eval set -- "$TEMP"


icon=":white_check_mark:"

while true ; do
  case "$1" in
    -m)
      message=$2 ; shift 2 ;;
    -u)
      url=$2 ; shift 2 ;;
    -i)
      icon=$2 ; shift 2 ;;
    -c)
      channel=$2 ; shift 2 ;;
    --) shift ; break ;;
    *) echo "Internal error!" ; exit 1 ;;
  esac
done

echo "Message: $message"
echo "URL: $url"
echo "Icon: $icon"

curl -X POST --data-urlencode "payload={'channel': '$channel', 'username': 'webhookbot', 'text': '$message'}" $url
#echo -X POST --data-urlencode "payload={'channel': '$channel', 'username': 'webhookbot', 'text': '$message', 'icon_emoji': '$icon'}" $url