#!/bin/sh

kubectl create deployment nginx$1 --image=nginx
kubectl expose deployment nginx$1 --port=80
subctl export service --namespace default nginx$1

sleep 2s
echo "Check global ingress IP for nginx service"
kubectl get globalingressip nginx$1
