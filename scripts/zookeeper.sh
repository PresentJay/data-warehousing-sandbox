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
            helm repo add bitnami https://charts.bitnami.com/bitnami
            helm install zookeeper bitnami/zookeeper --version "9.2.4" \
                --set replicaCount=3 \
                --set allowAnonymousLogin=true \
                --set persistence.storageClass="longhorn"
        ;;
        modify-nodes)
            helm upgrade zookeeper bitnami/zookeeper --version "9.2.4" \
                --set replicaCount=$2 \
                --set allowAnonymousLogin=true
        ;;
        u | uninstall)
            helm uninstall zookeeper
        ;;
    esac
done
