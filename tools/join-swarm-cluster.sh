#!/bin/bash

MANAGER_ADVERTISE_ADDR=`curl http://${COREOS_PRIVATE_IPV4}:4001/v2/keys/nodes/managers | jq -r '.node.nodes[0].value'`

if [ -n $MANAGER_ADVERTISE_ADDR ]; then
  echo "JOINING DOCKER SWARM..."
  docker swarm join --token `curl http://${COREOS_PRIVATE_IPV4}:4001/v2/keys/swarm/manager-join-token` ${MANAGER_ADVERTISE_ADDR}:2377
else
  echo "INITINALIZING DOCKER SWARM..."
  docker swarm init --advertise-addr ${COREOS_PRIVATE_IPV4}

  etcdctl set /swarm/manager-join-token `docker swarm join-token -q manager`
  etcdctl set /swarm/worker-join-token `docker swarm join-token -q worker`
fi
