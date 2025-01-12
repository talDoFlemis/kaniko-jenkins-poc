FROM golang:1.23.4-alpine AS builder
WORKDIR /app

RUN apk add --no-cache \
	ca-certificates \
	gcc \
	musl-dev

COPY go.mod /app/

RUN --mount=type=cache,target=/go/pkg/mod/ \
	--mount=type=bind,source=go.mod,target=go.mod \
	go mod download -x

COPY . .

RUN --mount=type=cache,target=/go/pkg/mod/ \
	--mount=type=cache,target="/app/.cache/go-build" \
	GOCACHE=/app/.cache/go-build \
	CGO_ENABLED=0 GOOS=linux go build -o server  -ldflags '-s -w -extldflags "-static"' ./main.go

FROM ubuntu:oracular AS user
RUN useradd -u 10001 scratchuser

FROM scratch
WORKDIR /app

COPY --from=builder /app/server ./
COPY --from=builder /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/
COPY --from=user /etc/passwd /etc/passwd

USER scratchuser
STOPSIGNAL SIGINT
EXPOSE 8080

CMD ["/app/server"]
