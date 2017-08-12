#!/bin/bash

cluster_config_dir=/etc/coreos-docker-swarm-cluster
slack=$cluster_config_dir/tools/send-message-to-slack.sh

MANAGER_ADVERTISE_ADDR=`curl http://${COREOS_PRIVATE_IPV4}:4001/v2/keys/nodes/managers | jq -r '.node.nodes[0].value'`

role=$1

if [ "$role" == "manager" ]; then

  if [ "$MANAGER_ADVERTISE_ADDR" = "null" ]; then
    echo "INITINALIZING DOCKER SWARM..."
    $slack -m "_${COREOS_PRIVATE_IPV4}_: Initiailizing docker swarm cluster" -u $SLACK_WEBHOOK_URL -c "$SLACK_CHANNEL"
    
    docker swarm init --advertise-addr ${COREOS_PRIVATE_IPV4}
    etcdctl set /swarm/manager-join-token `docker swarm join-token -q manager`
    etcdctl set /swarm/worker-join-token `docker swarm join-token -q worker`    
  else
    echo "JOINING DOCKER SWARM..."
    $slack -m "_${COREOS_PRIVATE_IPV4}_: Joining existing docker swarm cluster as $role" -u $SLACK_WEBHOOK_URL -c "$SLACK_CHANNEL"
    docker swarm join --token `curl http://${COREOS_PRIVATE_IPV4}:4001/v2/keys/swarm/manager-join-token | jq -r '.node.value'` ${MANAGER_ADVERTISE_ADDR}:2377
  fi

elif [ "$role" == "worker" ]; then

  token=`curl http://${COREOS_PRIVATE_IPV4}:4001/v2/keys/swarm/worker-join-token | jq -r '.node.value'`
  if [ "$token" == "null" ]; then
    echo "Failed to find join token for a worker node in the swarm cluster!"
    exit -1
  else 
    $slack -m "_${COREOS_PRIVATE_IPV4}_: Joining existing docker swarm cluster as $role" -u $SLACK_WEBHOOK_URL -c "$SLACK_CHANNEL"
    docker swarm join --token $token ${MANAGER_ADVERTISE_ADDR}:2377
  fi

else 
  echo "Unexpected role given: $role, expected either 'manager' or 'worker'!"
  exit -1
fi
