#!/bin/sh
# Create a pod with a shell in the default namespace from which network tests may be run.
kubectl -n default run tmp-shell --rm -i --tty --image quay.io/submariner/nettest -- /bin/bash
