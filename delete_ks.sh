#!/bin/bash
kubectl --namespace=kube-system delete deployments $@
kubectl --namespace=kube-system delete services $@
kubectl --namespace=kube-system delete rc $@
