#!/bin/bash

echo "------------------------------"
echo "BOOTSTRAP FOR $1 IS RUNNING"

set -o allexport
source /etc/custom-environment
set +o allexport

cluster_config_dir=/etc/coreos-docker-swarm-cluster
slack=$cluster_config_dir/tools/send-message-to-slack.sh

$slack -m "Bootstraping a *$1* node at ${COREOS_PRIVATE_IPV4}" -u $SLACK_WEBHOOK_URL -c #$SLACK_CHANNEL


unit_files="$cluster_config_dir/$1-systemd-units.txt"
cat $unit_files | while read unit
do
   echo "Starting unit: $unit..."
   cp -rf $cluster_config_dir/systemd-units/$unit /etc/systemd/system
   systemctl daemon-reload
   systemctl start $unit
   $slack -m "-- Started unit _${unit}_ on ${COREOS_PRIVATE_IPV4}" -u $SLACK_WEBHOOK_URL -c #$SLACK_CHANNEL
done

$slack -m "Bootstrap completed for *$1* node at ${COREOS_PRIVATE_IPV4}!" -u $SLACK_WEBHOOK_URL -c #$SLACK_CHANNEL

echo "BOOTSTRAP FOR $1 COMPLETED"
echo "------------------------------"