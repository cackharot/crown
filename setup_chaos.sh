#!/bin/bash

set +e
set +x

. ./chaos.env.sh
. ./utils.sh

if [ -f "${REGISTRY_DOMAIN_CERT}" ]; then
    echo "Using docker registry ${REGISTRY_DOMAIN_NAME}:${REGISTRY_DOMAIN_PORT}"
else
    echo 'Create self signed certificates for docker registry'
    source ./create_self_signed_certs.sh
    echo "Using docker registry ${REGISTRY_DOMAIN_NAME}:${REGISTRY_DOMAIN_PORT}"
fi

echo 'Setup ssh key pair on chaos server'
remote_exec ${PKEY} ${CHAOS_IP} '[ -f ~/.ssh/id_rsa  ] || ssh-keygen -b 2048 -t rsa -f ~/.ssh/id_rsa -q -N ""'
remote_copy ${PKEY} ${CHAOS_IP} '~/.ssh/id_rsa.pub' './chaos_id_rsa.pub'

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

