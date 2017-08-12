#!/bin/bash

set -o allexport
source /etc/custom-environment
set +o allexport

cluster_config_dir=/etc/coreos-docker-swarm-cluster
slack=$cluster_config_dir/tools/send-message-to-slack.sh

$slack -m "_${COREOS_PRIVATE_IPV4}_ Node is UP ($NODE_ROLE)" -u $SLACK_WEBHOOK_URL -c "$SLACK_CHANNEL"

while true; do
  /usr/bin/etcdctl set /nodes/${NODE_ROLE}s/${COREOS_PRIVATE_IPV4} "${COREOS_PRIVATE_IPV4}" --ttl 60;
  sleep 45;
done