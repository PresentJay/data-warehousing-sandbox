
source ./config/cluster.sh

VERSION=0.18.5

while getopts b-: OPT; do
    if [ $OPT = "-" ]; then
        OPT=${OPTARG%%=*}
        OPTARG=${OPTARG#$OPT}
        OPTARG=${OPTARG#=}
    fi
    case $OPT in
        i | install)
            kubectl apply -f https://raw.githubusercontent.com/Altinity/clickhouse-operator/${VERSION}/deploy/operator/clickhouse-operator-install-bundle.yaml
        ;;
    esac
done

