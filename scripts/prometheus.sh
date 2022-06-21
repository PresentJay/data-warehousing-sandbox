
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
            helm upgrade --install kube-stack-prometheus prometheus-community/kube-prometheus-stack \
                -n monitoring --create-namespace --set prometheus-node-exporter.hostRootFsMount.enabled=false --no-hooks
        ;;
        u | uninstall | d | delete)
            helm uninstall kube-stack-prometheus -n monitoring
            kubectl delete namespace monitoring
            helm repo remove prometheus-community
        ;;
    esac
done
