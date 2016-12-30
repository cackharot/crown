#!/bin/bash
kubectl delete deployments gocd-agent --namespace=chaos-gocd
kubectl create -f deployments/ops/gocd-agent.yml
