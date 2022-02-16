#!/bin/sh
# This script does creates and exports a service without selector.

SVC_POD_NAME=nginx-pod
SVC_NAME=nginx-svc
SVC_PORT=80
TARGET_PORT=80

# Create a service without selector

cat << EOF | kubectl apply -f -
apiVersion: v1
kind: Service
metadata:
  name: $SVC_NAME
spec:
  ports:
    - protocol: TCP
      port: $SVC_PORT
      targetPort: $TARGET_PORT
EOF

# Start a pod running nginx
kubectl run $SVC_POD_NAME --image=nginx --restart=Never

# Get the pod IP
MAX_TRIES=10
for i in $(seq 1 $MAX_TRIES); do
  SVC_POD_IP=$(kubectl get pods -n default $SVC_POD_NAME -o wide | grep $SVC_POD_NAME | awk '{print $6}')
  if [ -z "${SVC_POD_IP}" ] || [ "${SVC_POD_IP}" == "<none>" ]; then
    echo "IP address for pod $SVC_POD_NAME not ready yet"
    sleep 1
    continue
  else
    echo "IP address for pod $SVC_POD_NAME is $SVC_POD_IP"
    break
  fi
done

if [ -z "${SVC_POD_IP}" ] || [ "${SVC_POD_IP}" == "<none>" ]; then
  echo "ERROR: Failed to get IP address for pod $SVC_POD_NAME in $MAX_TRIES tries"
  exit 1
fi

# Associate nginx pod with service
cat << EOF | kubectl apply -f -
apiVersion: v1
kind: Endpoints
metadata:
  name: $SVC_NAME
subsets:
  - addresses:
      - ip: $SVC_POD_IP
    ports:
      - port: $SVC_PORT
EOF

# Export serivice
subctl export service -n default $SVC_NAME

