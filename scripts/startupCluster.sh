#!/bin/bash

# Author: PresentJay (정현재, presentj94@ust.ac.kr)

source ./config/cluster.sh
source ./config/common.sh

ITER=1
while [[ ${ITER} -lt ${NUM_NODES} ]]; do
    # cluster.sh 설정에 맞춰 노드 생성
    # 각 노드는 Ubuntu 21.10 OS 기반으로 함
    multipass launch \
        --name node${ITER} \
        --cpus ${NUM_CPUS} \
        --mem ${MEM_SIZE}G \
        --disk ${DISK_SIZE}G \
        21.10

    # 각 노드별 필수 유틸리티 설치 (nfs, iscsi : virtual storage 위한 설치)
    multipass exec node${ITER} -- sudo apt-get update -y 
    multipass exec node${ITER} -- sudo apt-get install nfs-common open-iscsi nfs-kernel-server -y
    
    if [[ ${ITER} -eq 1 ]]; then
        # Master node : k3s 설치
        # kubernetes version 고정, traefik 사용 해제(v1이기 때문), servicelb 사용 해제, 기본 스토리지 해제
        # feature gate인 TTLAfterFinished 설정 (Job 자동삭제)
        multipass exec node${ITER} -- bash -c "curl -sfL https://get.k3s.io | \
            INSTALL_K3S_VERSION=${K3S_VERSION} \
            sh -s - server \
            --disable traefik \
            --disable servicelb \
            --disable local-storage \
            --kube-apiserver-arg feature-gates=TTLAfterFinished=true"

        # Master node에 접근할 수 있는 인증 토큰 및 Endpoint 정보 저장
        K3S_TOKEN=$(multipass exec node1 -- bash -c "sudo cat /var/lib/rancher/k3s/server/node-token")
        K3S_URL=$(multipass info node1 | grep IPv4 | awk '{print $2}')
        K3S_URL_FULL="https://${K3S_URL}:6443"

        multipass exec node1 sudo cat /etc/rancher/k3s/k3s.yaml > config/kubeconfig.yaml
        set -i '' "s/127.0.0.1/${K3S_URL}/" config/kubeconfig.yaml
    else
        # Worker node : k3s 설치
        multipass exec node${ITER} -- bash -c "curl -sfL: https://get.k3s.io | \
            INSTALL_K3S_VERSION=${K3S_VERSION} \
            K3S_URL=${K3S_URL_FULL} \
            K3S_TOKEN=${K3S_TOKEN} \ 
            sh -"
    fi
    
    success "node${ITER} is set for k3s"
    ITER=$(( ITER+1 ))
done
unset ITER
