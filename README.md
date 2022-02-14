# submariner-gateway
Submariner External Network POC

This repo contains scripts that implement the external network POC defined in https://submariner.io/getting-started/quickstart/external/.

Prerequisites
See https://submariner.io/getting-started/quickstart/external/

Summary
- Setup 3 VMs as described
- Install subctl
- Install yq
- Additionally, the scripts currently assume that KUBECONFIG is exported as follows:
  - `export KUBECONFIG=kubeconfig.cluster-a` (on cluster-a)
  - `export KUBECONFIG=kubeconfig.cluster-b` (on cluster-b)
    
The steps to install are as follows
1. Modify config.sh as required
2. Execute `deploy-cluster.sh` on cluster-a
3. Execute `deploy-cluster.sh` on cluster-b
4. Confirm that the clusters are connected by running `subctl show all`
   The output should look something like the following:
   ```
    cluster-a:~/submariner-gateway$ subctl show all
    Cluster "default"
    ✓ Showing Connections
    GATEWAY    CLUSTER    REMOTE IP       NAT  CABLE DRIVER  SUBNETS       STATUS     RTT avg.    
    cluster-b  cluster-b  192.168.122.27  no   vxlan         242.1.0.0/16  connected  846.923µs
    
    ✓ Showing Endpoints
    CLUSTER ID                    ENDPOINT IP     PUBLIC IP       CABLE DRIVER        TYPE            
    cluster-a                     192.168.122.26  136.56.109.53   vxlan               local           
    cluster-b                     192.168.122.27  136.56.109.53   vxlan               remote
    
    ✓ Showing Gateways
    NODE                            HA STATUS       SUMMARY                         
    cluster-a                       active          All connections (1) are established
    
        Discovered network details via Submariner:
            Network plugin:  generic
            Service CIDRs:   [10.43.0.0/16]
            Cluster CIDRs:   [10.42.0.0/24,192.168.122.0/24]
            Global CIDR:     242.0.0.0/16
    ✓ Showing Network details
    
    COMPONENT                       REPOSITORY                                            VERSION         
    submariner                      quay.io/submariner                                    devel           
    submariner-operator             quay.io/submariner                                    devel           
    service-discovery               quay.io/submariner                                    devel           
    ✓ Showing versions

   ```
5. Execute `create-dns.sh` on cluster-a to deploy a DNS server on cluster-a for non-cluster hosts
6. Setup test-vm as defined here: https://submariner.io/getting-started/quickstart/external/#set-up-non-cluster-hosts
7. Execute `create-ext-svc.sh` on cluster-a to create Service, Endpoints, ServiceExport to access the test-vm from cluster pods
8. Execute `create-nginx-svc.sh` on cluster-b to create a test nginx service
   
Note: the next two steps are needed to workaround two existing bugs.  They won't be needed and will be 
removed after the bugs are fixed.

9. Execute `create-endpoint.sh <internal-service-name>` to manually create an endpoint for the external service.

10. Execute `create-endpointslice.sh` to create an endpoint slice for the external service.

11. Run various connectivity tests defined in https://submariner.io/getting-started/quickstart/external/
    
    For example

    - Start a webserver on test-vm by executing `sudo python -m http.server 80`
    - From test vm:
      ```
      curl nginx.default.svc.clusterset.local
      curl test-vm.default.svc.clusterset.local
      ```
    - From each cluster, start a "nettest" instance by executing `nettest.sh`.  Then
      ```
      curl nginx.default.svc.clusterset.local
      curl test-vm.default.svc.clusterset.local
      ```
            

