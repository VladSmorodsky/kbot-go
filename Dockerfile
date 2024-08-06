FROM golang:1.22.5 AS builder

WORKDIR /var/www/html
COPY . .
RUN make build

FROM scratch
WORKDIR /
COPY --from=builder /var/www/html/kbot-go .
COPY --from=alpine:latest /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/
ENTRYPOINT ["./kbot-go"]