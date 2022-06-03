#!/bin/bash

# Author: PresentJay (정현재, presentj94@ust.ac.kr)

### 로그코드 ###

kill() {
    echo >&2 "[ERROR] $@" && exit 1
}

info() {
    echo "[INFO] $@"
}

success() {
    echo "[SUCCESS] $@"
}

### 로그코드 끝 ###


### settings ###

PREFER_PROTOCOL="https" # OR "http"
INGRESS="ingress-nginx"
STORAGE="longhorn"

### settings 끝 ###