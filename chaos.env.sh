#!/bin/bash

export nodes="vagrant@172.16.0.253 vagrant@172.16.0.11 vagrant@172.16.0.12"
export roles="ai i i"
export NUM_MINIONS=${NUM_MINIONS:-3}
export SERVICE_CLUSTER_IP_RANGE=11.1.1.0/24
export FLANNEL_NET=192.168.0.0/16
export DNS_DOMAIN="walkure.net"
export DNS_SERVER_IP=11.1.1.254
export ALLOW_PRIVILEGED="true"

CHAOS_IP=${CHAOS_IP:-172.16.0.253}
DRONE_IPS=${DRONE_IPS:-"172.16.0.11,172.16.0.12"}
K_LOC=${KUBERNETES_LOC:-"~/kubernetes/cluster"}
PKEY=${PKEY:-".vagrant/machines/chaos/virtualbox/private_key"}
REGISTRY_DOMAIN_NAME="registry.walkure.net"
REGISTRY_DOMAIN_PORT='5000'
REGISTRY_DOMAIN_CERT="certs/${REGISTRY_DOMAIN_NAME}.crt"

KUBERNETES_SKIP_DOWNLOAD=${KUBERNETES_SKIP_DOWNLOAD:-true}
KUBERNETES_SKIP_CONFIRM=${KUBERNETES_SKIP_CONFIRM:-true}
