
source ./config/cluster.sh

VERSION=0.18.5

while getopts iu-: OPT; do
    if [ $OPT = "-" ]; then
        OPT=${OPTARG%%=*}
        OPTARG=${OPTARG#$OPT}
        OPTARG=${OPTARG#=}
    fi
    case $OPT in
        i | install)
            kubectl apply -f https://raw.githubusercontent.com/Altinity/clickhouse-operator/${VERSION}/deploy/operator/clickhouse-operator-install-bundle.yaml
            kubectl apply -f objects/clickhouse-pre.yaml
        ;;
        u | uninstall)
            kubectl delete -f objects/clickhouse-pre.yaml
        ;;
    esac
done

