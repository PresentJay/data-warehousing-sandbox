#!/bin/bash

# Author: PresentJay (정현재, presentj94@ust.ac.kr)

source ./config/cluster.sh

while getopts iucd-: OPT; do
    if [ $OPT = "-" ]; then
        OPT=${OPTARG%%=*}
        OPTARG=${OPTARG#$OPT}
        OPTARG=${OPTARG#=}
    fi
    case $OPT in
        i | init | c | create)
            helm repo add prometheus-community https://prometheus-community.github.io/helm-charts && helm repo update
            kubectl apply -f https://github.com/cert-manager/cert-manager/releases/download/v1.8.0/cert-manager.yaml
            sleep 20
            helm upgrade --install kube-stack-prometheus prometheus-community/kube-prometheus-stack \
                -n monitoring --create-namespace \
                --set prometheus-node-exporter.hostRootFsMount.enabled=false \
                --set prometheusOperator.admissionWebhooks.certManager.enabled=true
        ;;
        u | uninstall | d | delete)
            helm uninstall kube-stack-prometheus -n monitoring
            kubectl delete namespace monitoring
            helm repo remove prometheus-community
            kubectl delete -f https://github.com/cert-manager/cert-manager/releases/download/v1.8.0/cert-manager.yaml
        ;;
        monitor)
            if [[ -n $2 ]]; then
                cat <<EOF | kubectl apply -f -
apiVersion: monitoring.coreos.com/v1
kind: ServiceMonitor
metadata:
  name: $2-metrics
  namespace: monitoring
  labels:
    app.kubernetes.io/name: $2
spec:
  selector:
    matchLabels:
      app: $2-metrics
  endpoints:
  - port: TCP
EOF
            else
                kill "please give parameter"
            fi
        ;;
    esac
done
