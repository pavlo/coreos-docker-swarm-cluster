#!/bin/bash

echo "------------------------------"
echo "BOOTSTRAP FOR $1 IS RUNNING"

set -o allexport
source /etc/custom-environment
set +o allexport

cluster_config_dir=/etc/coreos-docker-swarm-cluster

unit_files="$cluster_config_dir/$1-systemd-units.txt"
cat $unit_files | while read unit
do
   echo "Starting unit: $unit..."
   cp -rf $cluster_config_dir/systemd-units/$unit /etc/systemd/system
   systemctl daemon-reload
   #systemctl enable $unit
   systemctl start $unit
done

echo "BOOTSTRAP FOR $1 COMPLETED"
echo "------------------------------"