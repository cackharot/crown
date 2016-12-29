#!/bin/bash
kubectl --namespace=chaos-gocd delete deployments $@
kubectl --namespace=chaos-gocd delete services $@
