#!/bin/bash

DNS_DOMAIN=${DNS_DOMAIN:-"walkure.net"}
DNS_SERVER_IP=${DNS_SERVER_IP:-"11.1.1.254"}
KUBECTL="kubectl"
ENABLE_DOCKER_REGISTRY=${ENABLE_DOCKER_REGISTRY:-true}
ENABLE_DNS_SERVER=${ENABLE_DNS_SERVER:-true}
ENABLE_GOCD=${ENABLE_GOCD:-true}
ENABLE_ELK=${ENABLE_ELK:-true}
ENABLE_DASHBOARD=${ENABLE_DASHBOARD:-true}
ENABLE_REGISTRY_UI=${ENABLE_REGISTRY_UI:-true}
KUBE_ROOT="deployments/ops"

echo 'Setup cluster addons'

install() {
    kubectl create -f "${KUBE_ROOT}/$1.yml" --record
    service_file="${KUBE_ROOT}/$1-service.yml"
    if [ -f "${service_file}"  ]; then
        kubectl create -f "${KUBE_ROOT}/$1-service.yml" --record
    fi
}

create_namespace() {
    RESULT=`eval "${KUBECTL} get namespaces | grep $1 | cat"`
    if [ ! "${RESULT}" ]; then
        kubectl create -f "${KUBE_ROOT}/$1.namespace.yml" --record
    else
        echo "Namespace '$1' already exists. Skipping"
    fi
}

install_gocd_ns_certs () {
    echo 'Creating kube secret for docker registry certifications'
    ${KUBECTL} --namespace=chaos-gocd delete secret registry-tls-secret
    ${KUBECTL} --namespace=chaos-gocd create secret generic registry-tls-secret \
        --from-file=ca.crt=certs/registry.walkure.net.crt
}

install_certs () {
    echo 'Creating kube secret for docker registry certifications'
    ${KUBECTL} --namespace=kube-system delete secret registry-tls-secret
    ${KUBECTL} --namespace=kube-system create secret generic registry-tls-secret \
        --from-file=ca.crt=certs/registry.walkure.net.crt \
        --from-file=domain.crt=certs/registry.walkure.net.crt \
        --from-file=domain.key=certs/registry.walkure.net.key
}

create_namespace 'chaos-gocd'
install_gocd_ns_certs

if [ $ENABLE_DOCKER_REGISTRY = true ]; then
    KUBEREGISTRY=`eval "${KUBECTL} get services --namespace=kube-system | grep kube-registry | cat"`
    if [ ! "$KUBEREGISTRY" ]; then
        echo 'Creating docker registry'
        install_certs
        install 'registry'
    else
        echo 'Kube registry already installed. Skipping'
    fi
fi

if [ $ENABLE_DNS_SERVER = true ]; then
    KUBEDNS=`eval "${KUBECTL} get services --namespace=kube-system | grep kube-dns | cat"`
    if [ ! "$KUBEDNS" ]; then
        echo 'Creating DNS Server'
        sed -e "s/\\\$DNS_DOMAIN/${DNS_DOMAIN}/g" "${KUBE_ROOT}/dns.yml.sed" > "${KUBE_ROOT}/dns.yml"
        sed -e "s/\\\$DNS_SERVER_IP/${DNS_SERVER_IP}/g" "${KUBE_ROOT}/dns-service.yml.sed" > "${KUBE_ROOT}/dns-service.yml"
        install 'dns'
    else
        echo 'DNS Server already installed. Skipping'
    fi
 fi

if [ $ENABLE_GOCD = true ]; then
    GOCD_SERVER=`eval "${KUBECTL} get services --namespace=chaos-gocd | grep gocd-server | cat"`
    if [ ! "${GOCD_SERVER}" ]; then
        echo 'Creating GoCD server and agents'
        install 'gocd-server'
        install 'gocd-agent'
    else
        echo 'GOCD already installed. Skipping'
    fi
fi

if [ $ENABLE_REGISTRY_UI = true ]; then
    echo 'Creating docker registry ui'
    install 'registry-ui'
fi

if [ $ENABLE_DASHBOARD = true ]; then
    echo 'Creating kubernetes ui dashboard'
    install 'dashboard'
fi

if [ $ENABLE_ELK = true ]; then
    echo 'Creating ELK stack'
    #install 'logstash'
    #install 'kibana'
fi
