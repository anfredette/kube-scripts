#!/bin/sh

kubectl create deployment nginx --image=nginx
kubectl expose deployment nginx --port=80
subctl export service --namespace default nginx

sleep 2s
echo "Check global ingress IP for nginx service"
kubectl get globalingressip nginx
