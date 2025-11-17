# Generate CA private key
openssl genrsa -out ca.key 2048

# Generate self-signed CA certificate
openssl req -x509 -new -nodes -key ca.key -subj "/CN=ns-resource-limiter-ca" -days 3650 -out ca.crt

# Generate webhook server private key
openssl genrsa -out tls.key 2048

# Generate CSR for the server certificate
openssl req -new -key tls.key -subj "/CN=ns-resource-limiter-ns-resource-limiter.default.svc" -out tls.csr

openssl x509 -req -in tls.csr -CA ca.crt -CAkey ca.key -CAcreateserial \
    -out tls.crt -days 365 -extfile tls-ext.cnf -extensions v3_ext

kubectl create secret tls ns-resource-limiter-tls \
  --cert=tls.crt \
  --key=tls.key \
  -n default

