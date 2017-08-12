#!/bin/bash

cluster_config_dir=/etc/coreos-docker-swarm-cluster
slack=$cluster_config_dir/tools/send-message-to-slack.sh

$slack -m "Bootstraping a *$1* node at ${COREOS_PRIVATE_IPV4}" -u $SLACK_WEBHOOK_URL -c "$SLACK_CHANNEL"

MANAGER_ADVERTISE_ADDR=`curl http://${COREOS_PRIVATE_IPV4}:4001/v2/keys/nodes/managers | jq -r '.node.nodes[0].value'`

role=$1

if [ "$role" == "manager" ]; then

  if [ -z $MANAGER_ADVERTISE_ADDR ]; then
    echo "INITINALIZING DOCKER SWARM..."
    $slack -m "Initiailizing docker swarm cluster at ${COREOS_PRIVATE_IPV4}" -u $SLACK_WEBHOOK_URL -c "$SLACK_CHANNEL"
    
    docker swarm init --advertise-addr ${COREOS_PRIVATE_IPV4}
    etcdctl set /swarm/manager-join-token `docker swarm join-token -q manager`
    etcdctl set /swarm/worker-join-token `docker swarm join-token -q worker`    
  else
    echo "JOINING DOCKER SWARM..."
    $slack -m "Joining existing docker swarm cluster as $role" -u $SLACK_WEBHOOK_URL -c "$SLACK_CHANNEL"
    docker swarm join --token `curl http://${COREOS_PRIVATE_IPV4}:4001/v2/keys/swarm/manager-join-token | jq -r '.node.value'` ${MANAGER_ADVERTISE_ADDR}:2377
  fi

elif [ "$role" == "worker" ]; then

  token=`curl http://${COREOS_PRIVATE_IPV4}:4001/v2/keys/swarm/worker-join-token | jq -r '.node.value'`
  if [ -n $token ]; then
    echo "docker swarm join --token $token ${MANAGER_ADVERTISE_ADDR}:2377"
  else 
    echo "Failed to find join token for a worker node in the swarm cluster!"
    exit -1
  fi

else 
  echo "Unexpected role given: $role, expected either 'manager' or 'worker'!"
  exit -1
fi
