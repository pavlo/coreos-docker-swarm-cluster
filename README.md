# coreos-docker-swarm-cluster

This project features a set of tools to automate the setup and maintenance of a docker swarm cluster on CoreOS.

## Cluster layout

There're two clusters actually - a [CoreOS cluster](https://coreos.com/os/docs/latest/cluster-architectures.html) and a [docker swarm](https://docs.docker.com/engine/swarm/) cluster on top of it. This means that the applications you run in the cluster can use `etcd` provided by the CoreOS which is incredibly handy in various situations.

![Image of Yaktocat](https://octodex.github.com/images/yaktocat.png)

## Tooling

In order to get it up and running you have to have the [Heatit!](https://github.com/pavlo/heatit) tool that is used to compile the  scripts into proper `cloud-config` files. 

todo: Provide direct links to download Heatit! binary