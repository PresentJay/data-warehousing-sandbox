#!/bin/bash

# Author: PresentJay (정현재, presentj94@ust.ac.kr)

# COUNT_NODES
NUM_NODES=3

# COUNT_CPUS
NUM_CPUS=2

# MEMORY_SIZE_GB
MEM_SIZE=2

# DISK_SIZE_GB
DISK_SIZE=256

# kubernetes version
K3S_VERSION="v1.20.15+k3s1"

KUBECONFIG_LOC="config/kubeconfig.yaml"

if [[ -e ${KUBECONFIG_LOC} ]]; then
    export KUBECONFIG=$(pwd)/${KUBECONFIG_LOC}
else
    echo "does not configed kubeconfig in your system."
    echo "if you run this system on multipass, try run like this [bash scripts/startupCluster.sh]"
    exit 1
fi