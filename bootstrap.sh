#!/bin/bash

echo "------------------------------"
echo "BOOTSTRAP FOR $1 IS RUNNING"

set -o allexport
source /etc/custom-environment
set +o allexport

unit_files="/etc/coreos-docker-swarm-cluster/$1-systemd-units.txt"
cat $unit_files | while read unit
do
   echo "Starting unit: $unit..."
   cp -rf ./systemd-units/$unit /etc/systemd/system
   #systemctl enable $unit
   systemctl start $unit
done

echo "BOOTSTRAP FOR $1 COMPLETED"
echo "------------------------------"