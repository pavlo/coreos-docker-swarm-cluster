#!/bin/bash

source /etc/custom-environment

# todo: parse required and optional params

curl -X POST --data-urlencode \
    "payload={'channel': '#aws-staging-events', 'username': 'webhookbot', 'text': 'Manager node at ${COREOS_PRIVATE_IPV4} is STARTED!', 'icon_emoji': ':white_check_mark:'}\" \
    @param:slack-webhook-url;