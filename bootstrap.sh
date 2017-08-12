#!/bin/bash

echo "------------------------------"
echo "BOOTSTRAP FOR $1 IS RUNNING"

while [ "`curl http://${COREOS_PRIVATE_IPV4}:4001/v2/keys/nodes/bootstrapping | jq -r '.node.value'`" != "null" ]; do
  echo "An other node is bootstrapping, waiting 5 seconds..."
  sleep 5
done

# Set a lock
etcdctl set /nodes/bootstrapping ${COREOS_PRIVATE_IPV4} --ttl 180

set -o allexport
source /etc/custom-environment
set +o allexport

cluster_config_dir=/etc/coreos-docker-swarm-cluster
slack=$cluster_config_dir/tools/send-message-to-slack.sh

$slack -m "Bootstraping a *$1* node at ${COREOS_PRIVATE_IPV4}" -u $SLACK_WEBHOOK_URL -c "#$SLACK_CHANNEL"

$cluster_config_dir/tools/join-swarm-cluster.sh $1

unit_files="$cluster_config_dir/$1-systemd-units.txt"
cat $unit_files | while read unit
do
   echo "Starting unit: $unit..."
   cp -rf $cluster_config_dir/systemd-units/$unit /etc/systemd/system
   systemctl daemon-reload
   systemctl start $unit
   $slack -m "-- Started unit _${unit}_ on ${COREOS_PRIVATE_IPV4}" -u $SLACK_WEBHOOK_URL -c "#$SLACK_CHANNEL"
done


$slack -m "Bootstrap completed for *$1* node at ${COREOS_PRIVATE_IPV4}!" -u $SLACK_WEBHOOK_URL -c "#$SLACK_CHANNEL"

# release the lock
etcdctl rm /nodes/bootstrapping

echo "BOOTSTRAP FOR $1 COMPLETED"
echo "------------------------------"