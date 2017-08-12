#!/bin/bash

set -o allexport
source /etc/custom-environment
set +o allexport

cluster_config_dir=/etc/coreos-docker-swarm-cluster
slack=$cluster_config_dir/tools/send-message-to-slack.sh

$slack -m "Node ${COREOS_PRIVATE_IPV4} ($NODE_ROLE) is DOWN" -u $SLACK_WEBHOOK_URL -c "$SLACK_CHANNEL"