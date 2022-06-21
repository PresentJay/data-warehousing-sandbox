#!/bin/bash

# Author: PresentJay (정현재, presentj94@ust.ac.kr)

source ./config/cluster.sh

while getopts iu-: OPT; do
    if [ $OPT = "-" ]; then
        OPT=${OPTARG%%=*}
        OPTARG=${OPTARG#$OPT}
        OPTARG=${OPTARG#=}
    fi
    case $OPT in
        i | install)
            kubectl apply -k objects/airbyte/overlays/stable
        ;;
        u | uninstall)
            kubectl delete -k objects/airbyte/overlays/stable
        ;;
    esac
done

