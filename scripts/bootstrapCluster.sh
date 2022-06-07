#!/bin/bash

# Author: PresentJay (정현재, presentj94@ust.ac.kr)

export KUBECONFIG=config/kubeconfig.yaml

### helm의 config permission error 제거 ###
chmod o-r config/kubeconfig.yaml
chmod g-r config/kubeconfig.yaml

### Ingress-Nginx 설치 (클러스터 내 트래픽 관리) ###
helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
helm repo update && \
    helm install ingress-nginx ingress-nginx/ingress-nginx -n ingress-nginx --create-namespace

### Longhorn Storage 설치 (클러스터 내 가상 스토리지 관리) ###
helm repo add longhorn https://charts.longhorn.io
helm repo update && \
    helm upgrade --install longhorn longhorn/longhorn --namespace longhorn-system --set csi.kubeletRootDir=/var/lib/kubelet --create-namespace

### Kubernetes Dashboard 설치 (클러스터 모니터링 도구) ###
helm repo add kubernetes-dashboard https://kubernetes.github.io/dashboard/
helm repo update && \
    helm upgrade --install kubernetes-dashboard kubernetes-dashboard/kubernetes-dashboard --namespace kubernetes-dashboard --create-namespace


