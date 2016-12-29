#!/bin/bash

EXPIRE_DAYS=`eval 'echo 365*5 | bc'`
DOMAIN_NAME='registry.walkure.net'
#ALT_DOMAIN_NAMES='DNS.1=walkure.net,DNS.2=registry.walkure.net,DNS.3=gocd.walkure.net'
COUNTRY_CODE='US'
STATE='Delaware'
LOCATION='Wilmington'
ORGINIZATION_NAME='Walkure'
CERTS_DIR="certs"

if [ ! -d $CERTS_DIR ]; then
    echo "Creating certs directory at ${CERTS_DIR}"
    mkdir -p "${CERTS_DIR}"
fi

openssl req -new -x509 -sha256 -newkey rsa:4096 -keyout "${CERTS_DIR}/${DOMAIN_NAME}.key" \
    -out "${CERTS_DIR}/${DOMAIN_NAME}.crt" -days ${EXPIRE_DAYS} -nodes \
    -subj "/C=${COUNTRY_CODE}/ST=${STATE}/L=${LOCATION}/O=${ORGINIZATION_NAME}/OU=Org/CN=${DOMAIN_NAME}"
    #-subj "/C=${COUNTRY_CODE}/ST=${STATE}/L=${LOCATION}/O=${ORGINIZATION_NAME}/OU=Org/CN=${DOMAIN_NAME}/subjectAltName=${ALT_DOMAIN_NAMES}"

