#!/bin/sh
# Create a pod with a shell in the default namespace from which network tests may be run.
# If called with a cp node name, then attempt to schedule the shell on the given node
# Assumes KUBECONFIG is set appropriately.


if [ -z "$1" ]; then
  kubectl -n default run tmp-shell --rm -i --tty --image quay.io/submariner/nettest -- /bin/bash
elif [ $1 == "cluster1-control-plane" ]; then
  kubectl -n default run tmp-shell --rm -i --tty --image quay.io/submariner/nettest --overrides='{"spec": { "nodeSelector": {"kubernetes.io/hostname": "cluster1-control-plane"}, "tolerations": [{"key": "node-role.kubernetes.io/master", "operator": "Exists","effect": "NoSchedule"}]}}' -- /bin/bash
elif [ $1 == "cluster2-control-plane" ]; then
  kubectl -n default run tmp-shell --rm -i --tty --image quay.io/submariner/nettest --overrides='{"spec": { "nodeSelector": {"kubernetes.io/hostname": "cluster2-control-plane"}, "tolerations": [{"key": "node-role.kubernetes.io/master", "operator": "Exists","effect": "NoSchedule"}]}}' -- /bin/bash
else
  echo "ERROR: Unsupported node name"
fi
