#!/bin/bash

./heatit process -s ./cloud-config.template.yml -p ./params.yml -d manager.yml --param-override=node-role=manager
echo -e "#cloud-config\n$(cat manager.yml)" > manager.yml

./heatit process -s ./cloud-config.template.yml -p ./params.yml -d worker.yml --param-override=node-role=worker
echo -e "#cloud-config\n$(cat worker.yml)" > worker.yml