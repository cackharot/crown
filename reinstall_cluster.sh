#!/bin/bash
set -e
set +x
. ./chaos.env.sh
. ./utils.sh

echo 'Stopping cluster services'
echo "Cluster master is $CHAOS_IP"

CMD='stop'
for SERVICE_NAME in flanneld etcd kubelet kube-apiserver;
do
    remote_exec ${PKEY} ${CHAOS_IP} "sudo service $SERVICE_NAME $CMD | grep 'stop/waiting' || true"
done

IFS=',' read -ra ADDR <<< "$DRONE_IPS"
cnt=1
for DRONE_IP in "${ADDR[@]}"; do
    DPKEY=".vagrant/machines/drone-${cnt}/virtualbox/private_key"
    cnt=$((cnt+1))
    echo "Restarting drone ${DRONE_IP}"
    for SERVICE_NAME in flanneld kubelet;
    do
        remote_exec ${DPKEY} ${DRONE_IP} "sudo service $SERVICE_NAME $CMD | grep 'stop/waiting' || true"
    done
done

echo 'Reinstalling cluster'
remote_exec ${PKEY} ${CHAOS_IP} "/bin/bash -c 'cd ~ && source /projects/crown/chaos.env.sh && cd ${K_LOC} && KUBERNETES_PROVIDER=ubuntu ./get-kube.sh'"

