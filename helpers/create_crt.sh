# variables
SERVICE=ns-resource-limiter-ns-resource-limiter
NAMESPACE=default
DAYS=365
CERT_DIR=./tls-certs

mkdir -p $CERT_DIR
cd $CERT_DIR

# generate CA key and cert
openssl genrsa -out ca.key 2048
openssl req -x509 -new -nodes -key ca.key -subj "/CN=${SERVICE}-ca" -days $DAYS -out ca.crt

# generate server key + CSR
openssl genrsa -out tls.key 2048
openssl req -new -key tls.key -subj "/CN=${SERVICE}.${NAMESPACE}.svc" -out tls.csr

# create an extfile with subjectAltName for the service FQDNs
cat > extfile.cnf <<EOF
subjectAltName = DNS:${SERVICE}.${NAMESPACE}.svc, DNS:${SERVICE}.${NAMESPACE}.svc.cluster.local
EOF

# sign the server cert with the CA, including SANs
openssl x509 -req -in tls.csr -CA ca.crt -CAkey ca.key -CAcreateserial \
  -out tls.crt -days $DAYS -extfile extfile.cnf


kubectl create secret tls ns-resource-limiter-tls \
  --cert=tls.crt --key=tls.key -n $NAMESPACE --dry-run=client -o yaml | kubectl apply -f -

export CA_BUNDLE=$(cat ./ca.crt | base64 -w0)

yq ".tls.caBundle = \"$CA_BUNDLE\"" ../chart/ns-resource-limiter/values.yaml > ../renderd.values.yaml