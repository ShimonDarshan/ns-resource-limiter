#! Need to use distroless
FROM alpine:latest

WORKDIR /root

#! need to fix this, the copy is copy the all files under the ./bin folder instead of the BINARY_NAME only
COPY ./bin/ns-resource-limiter .

EXPOSE 8443

CMD ["./ns-resource-limiter"]