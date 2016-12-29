#!/bin/bash

set +e
set +x

CHAOS_IP=${CHAOS_IP:-172.16.0.253}
DRONE_IPS=${DRONE_IPS:-"172.16.0.11,172.16.0.12"}
K_LOC=${KUBERNETES_LOC:-"~/kubernetes/cluster"}
PKEY=${PKEY:-".vagrant/machines/chaos/virtualbox/private_key"}
REGISTRY_DOMAIN_NAME="registry.walkure.net"
REGISTRY_DOMAIN_PORT='5000'
REGISTRY_DOMAIN_CERT="certs/${REGISTRY_DOMAIN_NAME}.crt"

if [ -f "${REGISTRY_DOMAIN_CERT}" ]; then
    echo "Using docker registry ${REGISTRY_DOMAIN_NAME}:${REGISTRY_DOMAIN_PORT}"
else
    echo 'Create self signed certificates for docker registry'
    source ./create_self_signed_certs.sh
    echo "Using docker registry ${REGISTRY_DOMAIN_NAME}:${REGISTRY_DOMAIN_PORT}"
fi

remote_copy() {
    key=$1
    user='vagrant'
    host=$2
    src_file=$3
    dest_file=$4
    scp -q -i ${key} ${user}@${host}:${src_file} ${dest_file}
}

local_copy() {
    key=$1
    user='vagrant'
    host=$2
    src_file=$3
    dest_file=$4
    scp -q -i ${key} ${src_file} ${user}@${host}:${dest_file}
}

remote_exec() {
    key=$1
    user='vagrant'
    host=$2
    cmd=$3
    ssh -i ${key} ${user}@${host} "$cmd"
    #echo "======================================="
}

echo 'Setup ssh key pair on chaos server'
remote_exec ${PKEY} ${CHAOS_IP} '[ -f ~/.ssh/id_rsa  ] || ssh-keygen -b 2048 -t rsa -f ~/.ssh/id_rsa -q -N ""'
remote_copy ${PKEY} ${CHAOS_IP} '~/.ssh/id_rsa.pub' './chaos_id_rsa.pub'
# Uncomment the below line for first time run
# remote_exec ${PKEY} ${CHAOS_IP} 'cat ~/.ssh/id_rsa.pub >> ~/.ssh/authorized_keys'

echo 'Copy self signed docker registry certificates to cluster nodes & master'
remote_exec ${PKEY} ${CHAOS_IP} "sudo mkdir -p /etc/docker/certs.d/${REGISTRY_DOMAIN_NAME}:${REGISTRY_DOMAIN_PORT}"
local_copy ${PKEY} ${CHAOS_IP} 'certs/registry.walkure.net.crt' "/tmp/ca.crt"
remote_exec ${PKEY} ${CHAOS_IP} "sudo cp /tmp/ca.crt /etc/docker/certs.d/${REGISTRY_DOMAIN_NAME}:${REGISTRY_DOMAIN_PORT}/ca.crt"

echo 'Stop etcd,flanned,kube services'
remote_exec ${PKEY} ${CHAOS_IP} '(sudo service etcd status | grep running) && sudo service etcd stop'
remote_exec ${PKEY} ${CHAOS_IP} '(sudo service flanneld status | grep running) && sudo service flanneld stop'

echo 'Copy chaos server pub key to all drones'
IFS=',' read -ra ADDR <<< "$DRONE_IPS"
cnt=1
for i in "${ADDR[@]}"; do
    DPKEY=".vagrant/machines/drone-${cnt}/virtualbox/private_key"
    cnt=$((cnt+1))
    local_copy ${DPKEY} ${i} './chaos_id_rsa.pub' '~/.ssh/chaos_id_rsa.pub'
    remote_exec ${DPKEY} ${i} '(sudo service flanneld status | grep running) && sudo service flanneld stop'
    # Uncomment the below line for first time run
    # remote_exec ${DPKEY} ${i} 'cat ~/.ssh/chaos_id_rsa.pub >> ~/.ssh/authorized_keys'
done

echo 'Setup cluster'
#remote_exec ${PKEY} ${CHAOS_IP} "/bin/bash -c 'cd ~ && source /projects/crown/chaos.env.sh && cd ${K_LOC} && KUBERNETES_PROVIDER=ubuntu ./get-kube.sh'"


