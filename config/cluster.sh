#!/bin/bash

# Author: PresentJay (정현재, presentj94@ust.ac.kr)

# COUNT_NODES
NUM_NODES=8

# COUNT_CPUS
NUM_CPUS=8

# MEMORY_SIZE_GB
MEM_SIZE=8

# DISK_SIZE_GB
DISK_SIZE=512

# kubernetes version
K3S_VERSION="v1.20.15+k3s1"

export KUBECONFIG=config/kubeconfig.yaml