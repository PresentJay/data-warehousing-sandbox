#!/bin/bash

# Author: PresentJay (정현재, presentj94@ust.ac.kr)

source config/common.sh
source ./config/cluster.sh

OS_name=$(uname -s)
case ${OS_name} in
    "Darwin"* | "Linux"*) OS_name="Linux" ;;
    "MINGW32"* | "MINGW64"* | "CYGWIN" ) OS_name="Windows" ;;
    *) kill "this OS(${OS_name}) is not supported yet." ;;
esac

LOCAL_ADDRESS=$(kubectl config view -o jsonpath="{.clusters[0].cluster.server}" | cut -d"/" -f3 | cut -d":" -f1)

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
---
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: longhorn-ui-ingress
  namespace: longhorn-system
  annotations:
    kubernetes.io/ingress.class: nginx
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

case ${OS_name} in
    "Linux")
      RUN="open"
      EXP="sh"
    ;;
    "Windows" )
      RUN="start"
      EXP="bat"
    ;;
esac

if [[ ${PREFER_PROTOCOL}="https" ]]; then
    PORT=$(kubectl get svc ingress-nginx-controller -n ingress-nginx -o jsonpath="{.spec.ports[1].nodePort}")
elif [[ ${PREFER_PROTOCOL}="http" ]]; then
    PORT=$(kubectl get svc ingress-nginx-controller -n ingress-nginx -o jsonpath="{.spec.ports[0].nodePort}")
else
    kill "PREFER_PROTOCOL env error: please check your config/common.sh"
fi

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
  cp longhorn.${EXP} /usr/local/bin/longhorn
fi
