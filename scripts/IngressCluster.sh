#!/bin/bash

# Author: PresentJay (정현재, presentj94@ust.ac.kr)

source ./config/common.sh
source ./config/cluster.sh

OS_name=$(uname -s)
case ${OS_name} in
    "Darwin"* | "Linux"*)
        OS_name="Linux"
        RUN="open"
        EXP="sh"
    ;;
    "MINGW32"* | "MINGW64"* | "CYGWIN" )
        OS_name="Windows"
        RUN="start"
        EXP="exe"
    ;;
    *) kill "this OS(${OS_name}) is not supported yet." ;;
esac

LOCAL_ADDRESS=$(kubectl config view -o jsonpath="{.clusters[0].cluster.server}" | cut -d"/" -f3 | cut -d":" -f1)

if [[ ${PREFER_PROTOCOL}="https" ]]; then
    PORT=$(kubectl get svc ingress-nginx-controller -n ingress-nginx -o jsonpath="{.spec.ports[1].nodePort}")
elif [[ ${PREFER_PROTOCOL}="http" ]]; then
    PORT=$(kubectl get svc ingress-nginx-controller -n ingress-nginx -o jsonpath="{.spec.ports[0].nodePort}")
else
    kill "PREFER_PROTOCOL env error: please check your config/common.sh"
fi


case $1 in
    k8s)
        cat <<EOF | kubectl apply -f -
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: kubernetes-dashboard
  namespace: kubernetes-dashboard
  annotations:
    kubernetes.io/ingress.class: nginx
    cert-manager.io/cluster-issuer: letsencrypt-staging
    nginx.ingress.kubernetes.io/backend-protocol: HTTPS
    kubernetes.io/proxy-body-size: "1tb"
spec:
  tls:
    - hosts:
        - dashboard.k8s.${LOCAL_ADDRESS}.nip.io
  rules:
    - host: dashboard.k8s.${LOCAL_ADDRESS}.nip.io
      http:
        paths:
          - path: /
            pathType: Prefix
            backend:
              service:
                name: kubernetes-dashboard
                port:
                  number: 443
---
apiVersion: v1
kind: ServiceAccount
metadata:
  name: admin-user
  namespace: kubernetes-dashboard
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: admin-user
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: cluster-admin
subjects:
  - kind: ServiceAccount
    name: admin-user
    namespace: kubernetes-dashboard
EOF
        [ -e k8s.${EXP} ] && rm k8s.${EXP}

        DEST="${PREFER_PROTOCOL}://dashboard.k8s.${LOCAL_ADDRESS}.nip.io:${PORT}"
        KUBEBOARD_SECRETNAME=$(kubectl -n kubernetes-dashboard get sa/admin-user -o jsonpath="{.secrets[0].name}")
        KUBEBOARD_TOKEN=$(kubectl get secret ${KUBEBOARD_SECRETNAME} -n kubernetes-dashboard -o go-template="{{.data.token | base64decode}}")
        cat > k8s.${EXP} << EOF
#!/bin/bash
KUBEBOARD_TOKEN="${KUBEBOARD_TOKEN}"
echo "[URL]"
echo "${DEST}"
echo "[TOKEN]"
echo "${KUBEBOARD_TOKEN}"
${RUN} ${DEST}
EOF

        chmod +x k8s.${EXP}
        chmod 777 k8s.${EXP}

        if [ ${OS_name} = "Linux" ]; then
          cp k8s.${EXP} /usr/local/bin/k8s
        fi

    ;;
    longhorn)
        cat <<EOF | kubectl apply -f -
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: longhorn-ui-ingress
  namespace: longhorn-system
  annotations:
    kubernetes.io/ingress.class: nginx
    kubernetes.io/proxy-body-size: "1tb"
spec:
  rules:
    - host: dashboard.longhorn.${LOCAL_ADDRESS}.nip.io
      http:
        paths:
          - pathType: ImplementationSpecific
            backend:
              service:
                name: longhorn-frontend
                port:
                  name: http
EOF
        [ -e longhorn.${EXP} ] && rm longhorn.${EXP}

        DEST="${PREFER_PROTOCOL}://dashboard.longhorn.${LOCAL_ADDRESS}.nip.io:${PORT}"

        if [[ ! -e longhorn.${EXP} ]]; then
            cat << EOF > longhorn.${EXP}
#!/bin/bash
echo "${DEST}"
${RUN} ${DEST}
EOF
        fi

        chmod +x longhorn.${EXP}
        chmod 777 longhorn.${EXP}


        if [ ${OS_name} = "Linux" ]; then
          cp longhorn.${EXP} /usr/local/bin/longhorn
        fi
    ;;
    prometheus)
        cat <<EOF | kubectl apply -f -
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: prometheus-ingress
  namespace: monitoring
  annotations:
    kubernetes.io/ingress.class: nginx
    kubernetes.io/proxy-body-size: "1tb"
spec:
  rules:
    - host: dashboard.prometheus.${LOCAL_ADDRESS}.nip.io
      http:
        paths:
          - pathType: ImplementationSpecific
            backend:
              service:
                name: kube-stack-prometheus-kube-prometheus
                port:
                  name: http-web
EOF
        [ -e prometheus.${EXP} ] && rm prometheus.${EXP}

        DEST="${PREFER_PROTOCOL}://dashboard.prometheus.${LOCAL_ADDRESS}.nip.io:${PORT}"

        if [[ ! -e prometheus.${EXP} ]]; then
            cat << EOF > prometheus.${EXP}
#!/bin/bash
echo "${DEST}"
${RUN} ${DEST}
EOF
        fi

        chmod +x prometheus.${EXP}
        chmod 777 prometheus.${EXP}

        if [ ${OS_name} = "Linux" ]; then
          cp prometheus.${EXP} /usr/local/bin/prometheus
        fi
    ;;
    grafana)
        cat <<EOF | kubectl apply -f -
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: grafana-ingress
  namespace: monitoring
  annotations:
    kubernetes.io/ingress.class: nginx
    kubernetes.io/proxy-body-size: "1tb"
spec:
  rules:
    - host: dashboard.grafana.${LOCAL_ADDRESS}.nip.io
      http:
        paths:
          - pathType: ImplementationSpecific
            backend:
              service:
                name: kube-stack-prometheus-grafana
                port:
                  name: http-web
EOF
        [ -e grafana.${EXP} ] && rm grafana.${EXP}

        DEST="${PREFER_PROTOCOL}://dashboard.grafana.${LOCAL_ADDRESS}.nip.io:${PORT}"

        if [[ ! -e grafana.${EXP} ]]; then
            cat << EOF > grafana.${EXP}
#!/bin/bash
echo "${DEST}"
echo "id: admin"
echo "pw: prom-operator"
${RUN} ${DEST}
EOF
        fi

        chmod +x grafana.${EXP}
        chmod 777 grafana.${EXP}

        if [ ${OS_name} = "Linux" ]; then
          cp grafana.${EXP} /usr/local/bin/grafana
        fi
    ;;
    clickhouse)
        cat <<EOF | kubectl apply -f -
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: clickhouse-ingress
  namespace: default
  annotations:
    kubernetes.io/ingress.class: nginx
    kubernetes.io/proxy-body-size: "1tb"
spec:
  rules:
    - host: clickhouse.${LOCAL_ADDRESS}.nip.io
      http:
        paths:
          - pathType: ImplementationSpecific
            backend:
              service:
                name: clickhouse-datawarehouse
                port:
                  name: http
EOF
        [ -e clickhouse.${EXP} ] && rm clickhouse.${EXP}

        DEST="${PREFER_PROTOCOL}://clickhouse.${LOCAL_ADDRESS}.nip.io:${PORT}/play"

        if [[ ! -e clickhouse.${EXP} ]]; then
            cat << EOF > clickhouse.${EXP}
#!/bin/bash
echo "${DEST}"
${RUN} ${DEST}
EOF
        fi

        chmod +x clickhouse.${EXP}
        chmod 777 clickhouse.${EXP}

        if [ ${OS_name} = "Linux" ]; then
          cp clickhouse.${EXP} /usr/local/bin/clickhouse
        fi
    ;;
    airbyte)
        cat <<EOF | kubectl apply -f -
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: airbyte-ingress
  namespace: default
  annotations:
    kubernetes.io/ingress.class: nginx
    kubernetes.io/proxy-body-size: "1tb"
spec:
  rules:
    - host: airbyte.${LOCAL_ADDRESS}.nip.io
      http:
        paths:
          - pathType: ImplementationSpecific
            backend:
              service:
                name: airbyte-webapp-svc
                port:
                  number: 80
EOF
        [ -e airbyte.${EXP} ] && rm airbyte.${EXP}

        DEST="${PREFER_PROTOCOL}://airbyte.${LOCAL_ADDRESS}.nip.io:${PORT}"

        if [[ ! -e airbyte.${EXP} ]]; then
            cat << EOF > airbyte.${EXP}
#!/bin/bash
echo "${DEST}"
${RUN} ${DEST}
EOF
        fi

        chmod +x airbyte.${EXP}
        chmod 777 airbyte.${EXP}

        if [ ${OS_name} = "Linux" ]; then
          cp airbyte.${EXP} /usr/local/bin/airbyte
        fi
    ;;
esac






