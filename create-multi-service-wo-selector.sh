#!/bin/sh
# This script does creates and exports a service without selector.

SVC_POD_NAME=nginx-mep-pod
SVC_NAME=nginx-mep-svc
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


# Start the endpoints file
cat << EOF > endpoints.yaml
apiVersion: v1
kind: Endpoints
metadata:
  name: $SVC_NAME
subsets:
  - addresses:
EOF

# Get the pod IP
NUM_PODS=3
for i in $(seq 1 $NUM_PODS); do

  # Start a pod running nginx
  POD_INSTANCE_NAME=$SVC_POD_NAME-$i
  kubectl run $POD_INSTANCE_NAME --image=nginx --restart=Never

  # Get the pod IP
  MAX_TRIES=10
  for j in $(seq 1 $MAX_TRIES); do
    SVC_POD_IP=$(kubectl get pods -n default $POD_INSTANCE_NAME -o wide | grep $POD_INSTANCE_NAME | awk '{print $6}')
    if [ -z "${SVC_POD_IP}" ] || [ "${SVC_POD_IP}" == "<none>" ]; then
      echo "IP address for pod $POD_INSTANCE_NAME not ready yet"
      sleep 1
      continue
    else
      echo "IP address for pod $POD_INSTANCE_NAME is $SVC_POD_IP"
      break
    fi
  done

  if [ -z "${SVC_POD_IP}" ] || [ "${SVC_POD_IP}" == "<none>" ]; then
    echo "ERROR: Failed to get IP address for pod $POD_INSTANCE_NAME in $MAX_TRIES tries"
    exit 1
  fi

  echo "      - ip: $SVC_POD_IP" >> endpoints.yaml
done

# finish the endpoints file
echo "    ports:" >> endpoints.yaml
echo "      - port: $SVC_PORT" >> endpoints.yaml

kubectl apply -f endpoints.yaml


# Export serivice
subctl export service -n default $SVC_NAME
