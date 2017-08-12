#!/bin/bash

source /etc/custom-environment

// todo: parse params


while true; do
  /usr/bin/etcdctl set /nodes/manager/${COREOS_PRIVATE_IPV4} ${COREOS_PRIVATE_IPV4} --ttl 60
  sleep 45
done