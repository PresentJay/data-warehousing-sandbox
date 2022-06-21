#!/bin/bash

# Author: PresentJay (정현재, presentj94@ust.ac.kr)

source ./config/cluster.sh

ITER=1
while [[ ${ITER} -le ${NUM_NODES} ]]; do
    multipass stop node${ITER}
    ITER=$(( ITER+1 ))
done