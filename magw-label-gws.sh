#!/bin/bash
# Add missing routes and iptables rules for multiple active gateway POC
# Assumptions:
# - commands and script are executed from the submariner-operator directory
# - Use KIND to depoloy two clusters with all defaults using the following command:
#   make deploy using=lighthouse,vxlan,globalnet DEPLOY_ARGS='--deploytool_submariner_args="--multi-active-gateway=true"'

C1_KUBECONFIG='output/kubeconfigs/kind-config-cluster1'
C2_KUBECONFIG='output/kubeconfigs/kind-config-cluster2'

# Label second gateways in each cluster
echo "Label cluster1-worker2"
kubectl --kubeconfig=$C1_KUBECONFIG label node cluster1-worker2 submariner.io/gateway=true
echo "Label cluster2-worker2"
kubectl --kubeconfig=$C2_KUBECONFIG label node cluster2-worker2 submariner.io/gateway=true
