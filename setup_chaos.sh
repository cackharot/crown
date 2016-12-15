#!/bin/bash

set +e
set +x

CHAOS_IP=${CHAOS_IP:-172.16.0.253}
DRONE_IPS=${DRONE_IPS:-"172.16.0.11,172.16.0.12"}
K_LOC=${KUBERNETES_LOC:-"~/kubernetes/cluster"}
PKEY=${PKEY:-".vagrant/machines/chaos/virtualbox/private_key"}

echo 'Setup ssh key pair on chaos server'
ssh -i ${PKEY} vagrant@${CHAOS_IP} '[ -f ~/.ssh/id_rsa ] || ssh-keygen -b 2048 -t rsa -f ~/.ssh/id_rsa -q -N ""' && \
    scp -q -i ${PKEY} vagrant@${CHAOS_IP}:~/.ssh/id_rsa.pub ./chaos_id_rsa.pub
#ssh -i ${PKEY} vagrant@${CHAOS_IP} 'cat ~/.ssh/id_rsa.pub >> ~/.ssh/authorized_keys'

echo 'Stop etcd,flanned,kube services'
ssh -i ${PKEY} vagrant@${CHAOS_IP} 'sudo service etcd stop && sudo service flanneld stop'

echo 'Copy chaos server pub key to all drones'
IFS=',' read -ra ADDR <<< "$DRONE_IPS"
cnt=1
for i in "${ADDR[@]}"; do
    DPKEY=".vagrant/machines/drone-${cnt}/virtualbox/private_key"
    cnt=$((cnt+1))
    scp -q -i ${DPKEY} ./chaos_id_rsa.pub vagrant@${i}:~/.ssh/chaos_id_rsa.pub
    ssh -i ${DPKEY} vagrant@${i} 'sudo service flanneld stop'
    #ssh -i ${DPKEY} vagrant@${i} 'cat ~/.ssh/chaos_id_rsa.pub >> ~/.ssh/authorized_keys'
done

echo 'Setup cluster'
scp -q -i ${PKEY} ./chaos.env.sh vagrant@${CHAOS_IP}:~/ && \
    ssh -i ${PKEY} vagrant@${CHAOS_IP} "/bin/bash -c 'cd ~ && source chaos.env.sh && cd ${K_LOC} && KUBERNETES_PROVIDER=ubuntu ./kube-up.sh'"
