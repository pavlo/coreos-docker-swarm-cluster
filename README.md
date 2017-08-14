# coreos-docker-swarm-cluster

This project features a set of tools to automate the setup and maintenance of a docker swarm cluster on CoreOS.

## Cluster layout

There're two clusters actually - a [CoreOS cluster](https://coreos.com/os/docs/latest/cluster-architectures.html) and a [docker swarm](https://docs.docker.com/engine/swarm/) cluster on top of it. This means that the applications you run in the cluster can use `etcd` provided by the CoreOS which is incredibly handy in various situations.

### The layout

Cluster layout would look like this:

![Cluster Layout](https://github.com/pavlo/coreos-docker-swarm-cluster/raw/develop/docs/images/cluster_layout.png)

So, it has either 1, 3 (shown on the diagram) or 5 manager nodes as well as arbitrary number of worker nodes.

So each manager node:

* Runs an `etcd` service
* Is a docker swarm manager node
* Has [Vault](https://www.vaultproject.io) service running with `etcd` as a storage backend (optional)

While every worker node:

* Runs `etcd` service in [proxy mode](https://coreos.com/etcd/docs/latest/v2/proxy.html) (so it does not participate in consensus but allows to read and write the K/V stuff)
* Is a docker swarm worker node

## How it works

The job is done in two distinct phases - generation of a `cloud-config` and `node bootstrapping`. The two topics are discussed in detail in the following sections.

### Generating of `cloud-config` file.

A `cloud-config` file is used to bootstrap a CoreOS node. It essentially is a declaration of how a CoreOS node would look like and consist of. Once it is generated, it can be used to provision EC2 instances, for instance:

![EC2 Cloud Config](https://github.com/pavlo/coreos-docker-swarm-cluster/raw/develop/docs/images/cloud_config_ec2.png)



## Tooling

In order to get it up and running you have to have the [Heatit!](https://github.com/pavlo/heatit) tool that is used to compile the  scripts into proper `cloud-config` files. 

todo: Provide direct links to download Heatit! binary