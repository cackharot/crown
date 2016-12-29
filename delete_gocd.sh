#!/bin/bash
kubectl delete service gocd-server --namespace=chaos-gocd
kubectl delete deployments gocd-server --namespace=chaos-gocd
kubectl delete deployments gocd-agent --namespace=chaos-gocd
