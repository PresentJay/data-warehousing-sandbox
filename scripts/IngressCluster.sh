#!/bin/bash

# Author: PresentJay (정현재, presentj94@ust.ac.kr)

source config/common.sh
source ./config/cluster.sh

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

kubectl patch deployment/kubernetes-dashboard \
    -n kubernetes-dashboard \
    --type=json \
    -p='[{\"op\": \"add\", \"path\": \"/spec/template/spec/containers/0/args/-\", \"value\": \"--token-ttl=43200\"}]'

if [[ ${PREFER_PROTOCOL}="https" ]]; then
    PORT=$(kubectl get svc ingress-nginx-controller -n ingress-nginx -o jsonpath="{.spec.ports[1].nodePort}")
elif [[ ${PREFER_PROTOCOL}="http" ]]; then
    PORT=$(kubectl get svc ingress-nginx-controller -n ingress-nginx -o jsonpath="{.spec.ports[0].nodePort}")
else
    kill "PREFER_PROTOCOL env error: please check your config/common.sh"
fi


[ -e longhorn.sh ] && rm longhorn.sh

DEST="${PREFER_PROTOCOL}://dashboard.longhorn.${LOCAL_ADDRESS}.nip.io:${PORT}"

case $(uname -s) in
    "Darwin"* | "Linux"*) RUN="open" ;;
    "MINGW32"* | "MINGW64"* | "CYGWIN" ) RUN="start" ;;
    *) kill "this OS($(uname -s)) is not supported yet." ;;
esac

if [[ ! -e longhorn.sh ]]; then
    cat << EOF > longhorn.sh
    #!/bin/bash
    echo "${DEST}"
    ${RUN} ${DEST}
EOF
fi

chmod +x longhorn.sh
chmod 777 longhorn.sh

[ -e k8s.sh ] && rm k8s.sh

DEST="${PREFER_PROTOCOL}://dashboard.k8s.${LOCAL_ADDRESS}.nip.io:${PORT}"
KUBEBOARD_SECRETNAME=$(kubectl -n kubernetes-dashboard get sa/admin-user -o jsonpath="{.secrets[0].name}")
KUBEBOARD_TOKEN=$(kubectl get secret ${KUBEBOARD_SECRETNAME} -n kubernetes-dashboard -o go-template="{{.data.token | base64decode}}")
cat > k8s.sh << EOF
    #!/bin/bash
    KUBEBOARD_TOKEN="${KUBEBOARD_TOKEN}"
    echo "[URL]"
    echo "${DEST}"
    echo "[TOKEN]"
    echo "${KUBEBOARD_TOKEN}"
    ${RUN} ${DEST}
EOF


chmod +x k8s.sh
chmod 777 k8s.sh

cp k8s.sh /usr/local/bin/k8s
cp longhorn.sh /usr/local/bin/longhorn
