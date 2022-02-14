#!/bin/bash
# BUG WORKAROUND: Manually create endpoint

SVC_NAME=nginx-svc
SVC_POD_NAME=nginx-pod
SVC_PORT=80
INTERNAL_SVC_NAME=$(kubectl get services -l submariner.io/exportedServiceRef=$SVC_NAME | grep submariner | awk '{print $1}')
SVC_IP=$(kubectl get services -n default $SVC_NAME -o wide | grep $SVC_NAME | awk '{print $3}')
SVC_POD_IP=$(kubectl get pods -n default $SVC_POD_NAME -o wide | grep $SVC_POD_NAME | awk '{print $6}')



cat << EOF | kubectl apply -f -
apiVersion: v1
kind: Endpoints
metadata:
  name: $INTERNAL_SVC_NAME
subsets:
  - addresses:
      - ip: $SVC_POD_IP
    ports:
      - port: $SVC_PORT
EOF
