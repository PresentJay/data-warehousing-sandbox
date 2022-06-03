#!/bin/bash

# Author: PresentJay (정현재, presentj94@ust.ac.kr)

source ./config/cluster.sh

ITER=${NUM_NODES}
while [[ ${ITER} -gt 0 ]]; do
    multipass delete node${ITER} -p &
    ITER=$(( ITER-1 ))
done && wait
unset ITER