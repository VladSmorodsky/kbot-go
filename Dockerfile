FROM golang:1.22.5 AS builder

ARG TARGET_ARCH[=arm64]
ARG TARGET_OS[=linux]

WORKDIR /var/www/html
COPY . .
RUN make build TARGET_ARCH=$TARGET_ARCH TARGET_OS=$TARGET_OS

FROM scratch
WORKDIR /
COPY --from=builder /var/www/html/kbot-go .
COPY --from=alpine:latest /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/
ENTRYPOINT ["./kbot-go"]