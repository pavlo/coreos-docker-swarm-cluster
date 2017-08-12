#!/bin/bash

./heatit process -s ./manager.template.yml -p ./params.yml -d manager.yml
echo -e "#cloud-config\n$(cat manager.yml)" > manager.yml