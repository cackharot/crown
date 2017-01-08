#!/bin/bash
kubectl exec -ti "$1" --namespace=chaos-gocd -- bash
