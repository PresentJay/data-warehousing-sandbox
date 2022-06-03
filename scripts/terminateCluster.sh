#!/bin/bash

# Author: PresentJay (정현재, presentj94@ust.ac.kr)

source ./config/cluster.sh

ITER=${NUM_NODES}
while [[ ${ITER} -gt 0 ]]; do
    multipass delete node${ITER} -p &
    ITER=$(( ITER-1 ))
done && wait
unset ITER

if [[ -e open_longhorn.sh ]]; then
    rm -v open_longhorn.sh 
fi

if [[ -e open_k8s.sh ]]; then
    rm -v open_k8s.sh
fi

if [[ -e /usr/local/bin/open_longhorn ]]; then
    rm -v /usr/local/bin/open_longhorn
fi

if [[ -e /usr/local/bin/open_k8s ]]; then
    rm -v /usr/local/bin/open_k8s
fi
