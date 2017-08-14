# coreos-docker-swarm-cluster

This project features a set of tools to automate the setup and maintenance of a docker swarm cluster on CoreOS.

## Cluster layout

Cluster layout would look like this:

![Cluster Layout](https://github.com/pavlo/coreos-docker-swarm-cluster/raw/develop/docs/images/cluster_layout.png)

So, it has either 1, 3 (shown on the diagram) or 5 manager nodes as well as arbitrary number of worker nodes.

### So each manager node:

* Runs an `etcd` service
* Is a docker swarm manager node
* Has [Vault](https://www.vaultproject.io) service running with `etcd` as a storage backend (optional)

### While every worker node:

* Runs `etcd` service in [proxy mode](https://coreos.com/etcd/docs/latest/v2/proxy.html) (so it does not participate in consensus but allows to read and write the K/V stuff)
* Is a docker swarm worker node

## Disclaimer 

The project does not make any assumptions on where you host the cluster and how you provision the boxes. Digitalocean or AWS or any other provider that allows to provision boxes with `user-data` or `cloud-config` stuff can be used.

It is outside the scope of the project to set up a secure network for the cluster - that is what one needs to do specifically using VPC and public/private subnets if AWS is used.


## How it works

The job is done in two distinct phases - generation of a `cloud-config` and node bootstrapping. The two topics are discussed in detail in the following sections.

### Generating the `cloud-config` file.

A `cloud-config` file is used to bootstrap a CoreOS node. It essentially is a declaration of how a CoreOS node would look like and consist of. Once it is generated, it can be used to provision CoreOS nodes.

Note, there're two cloud-config files need to be generated - the one for provisioning *manager* nodes and the other for provisioning *workers*.

Here's how a generation routine would look like these:

1. Generating cluster token (it assumes that there're 3 managers cluster is it):

    > curl https://discovery.etcd.io/new?size=3
    https://discovery.etcd.io/3c105a68331369250997be6369adac6c

2. Preparing the `params.yml` file that will be used as a source of configuration parameters during generation:

    > mv ./heatit/params.example.yml ./heatit/params.yml

3. Editing `./heatit/params.yml` - insert the cluster token generated in step #1 as a value for `coreos-cluster-token` parameter as well as set up Slack notification settings (todo: descripbe Slack setup in more detail)

4. Generate the two cloud-config files in a single command:

    > cd ./heatit; ./generate-configs.sh

This will produce two files: `manager.yml` and `worker.yml` in `./heatit` directory. Use them to provision your boxes. For example if AWS EC2 used, you can insert the contents of the file in the UI:

![EC2 Cloud Config](https://github.com/pavlo/coreos-docker-swarm-cluster/raw/develop/docs/images/cloud_config_aws_ec2.png) 

It is a one time operation - once the two are generated make sure you store the files in a safe place because you'll need to have them in order to provision more workers for instance, or add/replace managers.

### Node bootstrapping

This is where all interesting things begin! When a node that has been provisioned with either `master.yml` or `worker.yml` cloud-config file, boots up, it runs a single systemd unit called *Cluster Bootstrap*. See its declaration in `./heatit/systemd-units/cluster-bootstrap.service`. This service does two actions:

1. Clones *this* GIT repository in to `/etc/coreos-docker-swarm-cluster` folder on the CoreOS node
2. Executes `/etc/coreos-docker-swarm-cluster/bootstrap.sh` script

This simple approach allows easily to change the node configuration, services etc without re-creating the node which in some circumstances would save tons of time. All one needs is just reboot the node and let it re-clone the repository and start the boostrap routine from scratch while maintaining etcd and swarm cluster belongings. 

Then the `/etc/coreos-docker-swarm-cluster/bootstrap.sh` script, in its turn, reads a list of systemd units and runs them in order on the node. For the list of services to run on a *manager* nodes it reads `./manager-systemd-units.txt` file. For worker nodes it reads `./worker-systemd-units.txt` file. 

so, given the following is the content of `./manager-systemd-units.txt`:

    node-lifecycle.service
    vault.service
    vault-sk.service

then each time you provision a new node with master.yml file, or reboot an existing one, it would execute `node-lifecycle.service`, `vault.service` and then `vault-sk.service` on the node. Same applies to worker nodes with the exception is that it would read `./worker-systemd-units.txt` file.

## Tooling

Deprecated: In order to get it up and running you have to have the [Heatit!](https://github.com/pavlo/heatit) tool that is used to compile the  scripts into proper `cloud-config` files. 

todo: Provide direct links to download Heatit! binary