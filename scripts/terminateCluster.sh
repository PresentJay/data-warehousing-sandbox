#!/bin/bash

# Author: PresentJay (정현재, presentj94@ust.ac.kr)

source ./config/cluster.sh

ITER=${NUM_NODES}
while [[ ${ITER} -gt 0 ]]; do
    multipass delete node${ITER} -p &
    ITER=$(( ITER-1 ))
done && wait
unset ITER

if [[ -e longhorn.sh ]]; then
    echo -n "[DELETE] "
    rm -v longhorn.sh 
fi

if [[ -e k8s.sh ]]; then
    echo -n "[DELETE] "
    rm -v k8s.sh
fi

if [[ -e /usr/local/bin/longhorn ]]; then
    echo -n "[DELETE] "
    rm -v /usr/local/bin/longhorn
fi

if [[ -e /usr/local/bin/k8s ]]; then
    echo -n "[DELETE] "
    rm -v /usr/local/bin/k8s
fi
