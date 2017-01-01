#!/bin/bash

keytool -importcert -file certs/registry.walkure.net.crt -alias ca -keystore /export/registry/truststore -storepass password -noprompt
