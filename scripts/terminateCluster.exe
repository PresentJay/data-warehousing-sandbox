#!/bin/bash

# Author: PresentJay (정현재, presentj94@ust.ac.kr)

source ./config/cluster.sh

ITER=${NUM_NODES}
while [[ ${ITER} -gt 0 ]]; do
    multipass delete node${ITER} -p &
    ITER=$(( ITER-1 ))
done && wait
unset ITER

OS_name=$(uname -s)
case ${OS_name} in
    "Darwin"* | "Linux"*)
        EXP="sh"
    ;;
    "MINGW32"* | "MINGW64"* | "CYGWIN" )
        EXP="exe"
    ;;
    *) kill "this OS(${OS_name}) is not supported yet." ;;
esac


deleteCmd() {
    if [[ -e $1 ]]; then
        echo -n "[DELETE] "
        rm -v $1
    fi
    if [[ -e /usr/local/bin/$1 ]]; then
        echo -n "[DELETE] "
        rm -v /usr/local/bin/$1
    fi
}

deleteCmd longhorn.$EXT
deleteCmd k8s.$EXT
deleteCmd prometheus.$EXT
