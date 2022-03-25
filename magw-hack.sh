#!/bin/bash
# Add missing routes and iptables rules for multiple active gateway POC
# Assumptions:
# - commands and script are executed from the submariner-operator directory
# - Use KIND to depoloy two clusters with all defaults using the following command:
#   make deploy using=lighthouse,vxlan,globalnet DEPLOY_ARGS='--deploytool_submariner_args="--multi-active-gateway=true"'

C1_GEIP_BASE='242.254.1'
C1_GW1_NAME='cluster1-worker'
C1_GW2_NAME='cluster1-worker2'
C1_KUBECONFIG='output/kubeconfigs/kind-config-cluster1'

C2_GEIP_BASE='242.254.2'
C2_GW1_NAME='cluster2-worker'
C2_GW2_NAME='cluster2-worker2'
C2_KUBECONFIG='output/kubeconfigs/kind-config-cluster2'

# $1: node name
get_tunnel_ip () {
  IP_CIDER=$(docker exec -it $1 ip address show dev vxlan-tunnel | grep inet | awk '{print $2}')
  IFS='/'; CIDR_ARR=($IP_CIDER); unset IFS;
  IP_ADDR=${CIDR_ARR[0]}
}

# $1: node name, $2: remote global egress IP base, $3: remote GW1 tunnel IP, $4: remote GW2 tunnel IP
add_routes () {
  for i in {1..8}
  do
    docker exec -it $1 ip route add $2.$i table 100 metric 50 via $3 dev vxlan-tunnel
  done

  for i in {9..16}
  do
    docker exec -it $1 ip route add $2.$i table 100 metric 50 via $4 dev vxlan-tunnel
  done
}

# Label second gateways in each cluster
echo "Label cluster1-worker2"
kubectl --kubeconfig=$C1_KUBECONFIG label node cluster1-worker2 submariner.io/gateway=true
echo "Label cluster2-worker2"
kubectl --kubeconfig=$C2_KUBECONFIG label node cluster2-worker2 submariner.io/gateway=true
# Wait a few seconds for things to get setup
echo "Wait 10 seconds..."
sleep 10

# Fix up cluster1 gateway 2 iptables rules
docker exec -it $C1_GW2_NAME iptables -t nat -D SM-GN-EGRESS-CLUSTER -s 10.0.0.0/16 -m mark --mark 0xc0000/0xc0000 -j SNAT --to-source $C1_GEIP_BASE.1-$C1_GEIP_BASE.8
docker exec -it $C1_GW2_NAME iptables -t nat -D SM-GN-EGRESS-CLUSTER -s 100.0.0.0/16 -m mark --mark 0xc0000/0xc0000 -j SNAT --to-source $C1_GEIP_BASE.1-$C1_GEIP_BASE.8
docker exec -it $C1_GW2_NAME iptables -t nat -A SM-GN-EGRESS-CLUSTER -s 10.0.0.0/16 -m mark --mark 0xc0000/0xc0000 -j SNAT --to-source $C1_GEIP_BASE.9-$C1_GEIP_BASE.16
docker exec -it $C1_GW2_NAME iptables -t nat -A SM-GN-EGRESS-CLUSTER -s 100.0.0.0/16 -m mark --mark 0xc0000/0xc0000 -j SNAT --to-source $C1_GEIP_BASE.9-$C1_GEIP_BASE.16

# Add routes to cluster1 gateways for remote Global Egress IP's

get_tunnel_ip $C2_GW1_NAME
C2_GW1_TUNNEL_IP=$IP_ADDR

get_tunnel_ip $C2_GW2_NAME
C2_GW2_TUNNEL_IP=$IP_ADDR

add_routes $C1_GW1_NAME $C2_GEIP_BASE $C2_GW1_TUNNEL_IP $C2_GW2_TUNNEL_IP
add_routes $C1_GW2_NAME $C2_GEIP_BASE $C2_GW1_TUNNEL_IP $C2_GW2_TUNNEL_IP

# Fix up cluster2 gateway 2 iptables rules
docker exec -it $C2_GW2_NAME iptables -t nat -D SM-GN-EGRESS-CLUSTER -s 10.0.0.0/16 -m mark --mark 0xc0000/0xc0000 -j SNAT --to-source $C2_GEIP_BASE.1-$C2_GEIP_BASE.8
docker exec -it $C2_GW2_NAME iptables -t nat -D SM-GN-EGRESS-CLUSTER -s 100.0.0.0/16 -m mark --mark 0xc0000/0xc0000 -j SNAT --to-source $C2_GEIP_BASE.1-$C2_GEIP_BASE.8
docker exec -it $C2_GW2_NAME iptables -t nat -A SM-GN-EGRESS-CLUSTER -s 10.0.0.0/16 -m mark --mark 0xc0000/0xc0000 -j SNAT --to-source $C2_GEIP_BASE.9-$C2_GEIP_BASE.16
docker exec -it $C2_GW2_NAME iptables -t nat -A SM-GN-EGRESS-CLUSTER -s 100.0.0.0/16 -m mark --mark 0xc0000/0xc0000 -j SNAT --to-source $C2_GEIP_BASE.9-$C2_GEIP_BASE.16

# Add routes to cluster2 gateways for remote Global Egress IP's

get_tunnel_ip $C1_GW1_NAME
C1_GW1_TUNNEL_IP=$IP_ADDR

get_tunnel_ip $C1_GW2_NAME
C1_GW2_TUNNEL_IP=$IP_ADDR

add_routes $C2_GW1_NAME $C1_GEIP_BASE $C1_GW1_TUNNEL_IP $C1_GW2_TUNNEL_IP
add_routes $C2_GW2_NAME $C1_GEIP_BASE $C1_GW1_TUNNEL_IP $C1_GW2_TUNNEL_IP
