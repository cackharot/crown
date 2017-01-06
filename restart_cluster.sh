#!/bin/bash
set -e
set +x
. ./chaos.env.sh
. ./utils.sh

echo 'Restarting cluster services'
echo "Cluster master is $CHAOS_IP"

CMD='restart'
for SERVICE_NAME in flanneld etcd kubelet kube-apiserver;
do
    remote_exec ${PKEY} ${CHAOS_IP} "sudo service $SERVICE_NAME $CMD"
done

IFS=',' read -ra ADDR <<< "$DRONE_IPS"
cnt=1
for DRONE_IP in "${ADDR[@]}"; do
    DPKEY=".vagrant/machines/drone-${cnt}/virtualbox/private_key"
    cnt=$((cnt+1))
    echo "Restarting drone ${DRONE_IP}"
    for SERVICE_NAME in flanneld kubelet;
    do
        remote_exec ${DPKEY} ${DRONE_IP} "sudo service $SERVICE_NAME $CMD"
    done
done


