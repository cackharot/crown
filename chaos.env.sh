#!/bin/bash

export nodes="vagrant@172.16.0.253 vagrant@172.16.0.11 vagrant@172.16.0.12"

export roles="ai i i"

export NUM_MINIONS=${NUM_MINIONS:-3}

export SERVICE_CLUSTER_IP_RANGE=11.1.1.0/24

export FLANNEL_NET=192.168.0.0/16
